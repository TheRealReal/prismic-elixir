defmodule Prismic.SearchForm do
  @moduledoc """
  a submittable form comprised of an api, a prismic form, and data (queries, ref)
  """
  alias Prismic.{API, Form, Parser, Predicate, Ref, SearchForm}

  defstruct [:api, :form, :data]

  @type t :: %__MODULE__{
          api: API.t(),
          form: Form.t(),
          data: Map.t()
        }

  @spec from_api(API.t(), :everything, Map.t(), Map.t()) :: SearchForm.t() | nil
  def from_api(api = %API{forms: forms}, name \\ :everything, data \\ %{}, ref \\ %{}) do
    if form = forms[name], do: SearchForm.new(api, form, data, ref)
  end

  @spec new(API.t(), Form.t(), Map.t(), Map.t()) :: t()
  def new(api, form = %Form{fields: fields}, data \\ %{}, _ref \\ %{}) do
    default_data =
      fields
      |> build_default_data()
      |> Map.merge(data)

    struct(__MODULE__, api: api, form: form, data: default_data)
  end

  @doc """
  Forms contain fields, some of which are copied onto a search form ( those with default values ).
  If the fields are tagged with "multiple", they must be parsed into a list from a string representation of a list
  i.e. "[1]" -> ["1"]
  Later, when submitting queries, they are put back into this string form, but they must be in an elixir list in order to be manipulated when building queries.
  """
  def build_default_data(fields) do
    for {k, v} <- fields, !is_nil(v[:default]) do
      {k, parse_default_field(v)}
    end
    |> Enum.into(%{})
  end

  defp parse_default_field(%{multiple: true, default: default}) do
    default
    |> String.replace_prefix("[", "")
    |> String.replace_suffix("]", "")
    |> List.wrap()
  end

  defp parse_default_field(%{default: default}), do: default

  @doc """
  Serialize query params and also set master ref if ref has not been set, and submit the form
  """
  def submit(%SearchForm{form: %Form{action: action}, data: data = %{:ref => ref}})
      when not is_nil(ref) do
    params =
      data
      |> Enum.map(fn {k, v} -> {k, finalize_query(v)} end)
      |> Enum.into([])

    case HTTPoison.get(action, [], params: params) do
      {:ok, %{body: body}} ->
        body
        |> Poison.decode!(keys: :atoms)
        |> Parser.parse_response()

      # TODO: handle exception
      :error ->
        :error
    end
  end

  def submit(search_form = %SearchForm{}) do
    search_form
    |> set_ref("Master")
    |> submit()
  end

  def set_ref(search_form = %SearchForm{}, %Ref{ref: ref}) do
    set_data_field(search_form, :ref, ref)
  end
  def set_ref(search_form = %SearchForm{api: api = %API{}}, ref_label) do
    case API.find_ref(api, ref_label) do
      %Ref{ref: ref} ->
        set_data_field(search_form, :ref, ref)

      nil ->
        # TODO: create an exception type
        raise "ref #{ref_label} not found!"
    end
  end

  # @spec set_predicates(Form.t, [Prismic.Predicate.t])
  def set_query_predicates(search_form, predicates) do
    query = Enum.map(predicates, &Predicate.to_query/1)
    set_data_field(search_form, :q, query)
  end

  def set_data_field(search_form = %SearchForm{form: form, data: data}, field_name, value) do
    new_data =
      case form.fields[field_name] do
        %{multiple: true} ->
          wrapped_value = List.wrap(value)
          Map.update(data, field_name, wrapped_value, &Enum.concat(wrapped_value, List.wrap(&1)))

        _ ->
          Map.put(data, field_name, value)
      end

    put_in(search_form.data, new_data)
  end

  @doc "we must make a query string friendly version of a prismic query list, other data types are query encodable already"
  def finalize_query(query) when is_list(query), do: "[#{query}]"
  def finalize_query(query), do: query
end
