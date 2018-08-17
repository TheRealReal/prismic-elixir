defmodule Prismic do
  require Logger
  alias Prismic.{API, Cache, Document, Predicate, Ref, SearchForm}

  defp repo_url, do: Application.get_env(:prismic, :repo_url)

  def api(url \\ repo_url()) do
    # TODO: include access token in cache key after supporting tokens
    # + (access_token ? ('#' + access_token) : '')
    api_cache_key = url

    entrypoint_response =
      Cache.get_or_store(api_cache_key, fn ->
        case Prismic.HTTPClient.get(url) do
          {:ok, %{status_code: 200}} = response ->
            {:commit, response}

          response ->
            {:ignore, response}
        end
      end)

    case entrypoint_response do
      {:ok, %{body: body, status_code: status_code}} when status_code != 200 ->
        {:error, body}

      {:ok, %{body: body}} ->
        API.new(body, url)

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Retrieve all documents (paginated)
  param opts map query options (page, pageSize, ref, etc.)
  """
  def all(opts \\ %{}) do
    with {:ok, search_form} <- everything_search_form(opts) do
      submit_and_extract_results(search_form)
    else
      {:error, _error} = error -> error
    end
  end

  @doc """
  Return all documents matching given query parameters.
  This function has several clauses which generate queries from parameters
  passed in a map. For clients who need more fine-grained control over the
  query, there's also a clause which takes an arbitrary list of `Predicate`s.
  """
  @spec documents(map() | [Predicate.t()], map()) :: {:ok, [Document.t()]} | {:error, map()}
  def documents(args, opts \\ %{})

  @doc """
  Retrieve one document by its id
  param id [String] the id to search
  param opts [Map] query options (page, pageSize, ref, etc.)
  return list with one or 0 documents
  """
  def documents(%{id: id}, opts) do
    with {:ok, search_form} <- everything_search_form(opts) do
      search_form
      |> SearchForm.set_query_predicates([Predicate.at("document.id", id)])
      |> submit_and_extract_results()
    end
  end

  @doc """
  Retrieve document by its uid
  param type [String] the document type's name
  param uid [String] the uid to search
  param opts [Map] query options (ref, etc.)
  return list with one or 0 documents
  """
  def documents(%{type: type, uid: uid}, opts) do
    with {:ok, %SearchForm{} = search_form} <- everything_search_form(opts) do
      search_form
      |> SearchForm.set_query_predicates([Predicate.at("my." <> type <> ".uid", uid)])
      |> submit_and_extract_results()
    end
  end

  @doc """
  Retrieve multiple documents by their ids
  @param ids [String] the ids to fetch
  @param opts [map] query options (page, pageSize, ref, etc.)
  @return the documents, or [] if not found
  """
  def documents(%{ids: ids}, opts) do
    with {:ok, search_form} <- everything_search_form(opts) do
      search_form
      |> SearchForm.set_query_predicates([Predicate.where_in("document.id", ids)])
      |> submit_and_extract_results()
    end
  end

  def documents(%{tags: tags, type: type}, opts) do
    with {:ok, search_form} <- everything_search_form(opts) do
      search_form
      |> SearchForm.set_query_predicates([
        Predicate.at("document.tags", tags),
        Predicate.at("document.type", type)
      ])
      |> submit_and_extract_results()
    end
  end

  def documents(
        %{
          type: type,
          latitude: latitude,
          longitude: longitude,
          radius: radius,
          location_api_id: api_id
        },
        opts
      ) do
    with {:ok, search_form} <- everything_search_form(opts) do
      search_form
      |> SearchForm.set_query_predicates([
        Predicate.near("my.#{type}.#{api_id}", latitude, longitude, radius),
        Predicate.at("document.type", type)
      ])
      |> submit_and_extract_results()
    end
  end

  def documents(
        %{
          type: type,
          min_value: min_value,
          max_value: max_value,
          min_value_field: min_value_field,
          max_value_field: max_value_field
        },
        opts
      ) do
    with {:ok, search_form} <- everything_search_form(opts) do
      search_form
      |> SearchForm.set_query_predicates([
        Predicate.lt("my.#{type}.#{min_value_field}", min_value),
        Predicate.gt("my.#{type}.#{max_value_field}", max_value),
        Predicate.at("document.type", type)
      ])
      |> submit_and_extract_results()
    end
  end

  def documents(%{type: type}, opts) do
    with {:ok, search_form} <- everything_search_form(opts) do
      search_form
      |> SearchForm.set_query_predicates([Predicate.at("document.type", type)])
      |> submit_and_extract_results()
    end
  end

  def documents(predicates, opts) when is_list(predicates) and predicates != [] do
    with {:ok, search_form} <- everything_search_form(opts) do
      search_form
      |> SearchForm.set_query_predicates(predicates)
      |> submit_and_extract_results()
    end
  end

  @doc """
  Return the URL to display a given preview
  @param token [String] as received from Prismic server to identify the content to preview
  @return [String] the URL to redirect the user to
  """
  def preview_documents(token) do
    token = token |> URI.decode()

    with {:ok, %{status_code: 200, body: body}} <- Prismic.HTTPClient.get(token),
         {:ok, json} = Poison.decode(body),
         {:ok, search_form} = everything_search_form() do
      search_form
      |> SearchForm.set_query_predicates([Predicate.at("document.id", json["mainDocument"])])
      |> SearchForm.set_data_field(:ref, token)
      |> submit_and_extract_results()
    else
      _ -> {:ok, []}
    end
  end

  def everything_search_form(opts \\ %{}) do
    with {:ok, api} <- api(opts[:repo_url] || repo_url()),
         %Ref{} = ref <- opts[:ref] || API.find_ref(api, "Master"),
         %SearchForm{} = search_form <- SearchForm.from_api(api) do
      search_form =
        if token = opts[:preview_token] do
          SearchForm.set_data_field(search_form, :ref, token)
        else
          SearchForm.set_ref(search_form, ref)
        end

      {:ok, search_form}
    else
      {:error, _error} = error ->
        error
    end
  end

  defp submit_and_extract_results(%SearchForm{} = search_form) do
    Cache.get_or_store(inspect(search_form), fn ->
      case SearchForm.submit(search_form) do
        {:ok, response} ->
          {:ok, Map.get(response, :results, [])}

        {:error, _response} = response ->
          response
      end
    end)
  end
end
