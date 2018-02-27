defmodule Prismic do
  alias Prismic.{API, Cache, Predicate, SearchForm}

  defp repo_url, do: Application.get_env(:prismic, :repo_url)

  def api(url \\ repo_url()) do
    #TODO: include acces token in cache key after supporting tokens
    api_cache_key = url #+ (access_token ? ('#' + access_token) : '')
    entrypoint_response = Cache.get_or_store(api_cache_key, fn ->
      case Prismic.HTTPClient.get(url) do
        {:ok, %{status_code: 200}} = response ->
          {:commit, response}
        response ->
          {:ignore, response}
      end
    end)

    case entrypoint_response do
      {:ok, %{body: body}} ->
        API.new(body, url)
      {:error, error} -> {:error, error}
    end

  end

  @doc """
  Retrieve all documents (paginated)
  @param opts [Hash] query options (page, pageSize, ref, etc.)
  """
  def all(opts \\ %{}) do
    opts
    |> everything_search_form()
    |> SearchForm.submit()
    |> Map.get(:results, [])
  end

  @doc "takes map which will match on different bodies to generate queries and
  return documents"
  def documents(args, opts \\ %{})
  @doc """
  Retrieve one document by its id
  param id [String] the id to search
  param opts [Map] query options (page, pageSize, ref, etc.)
  return the document, or nil if not found
  """
  def documents(%{id: id}, opts) do
    everything_search_form(opts)
    |> SearchForm.set_query_predicates([Predicate.at("document.id", id)])
    |> SearchForm.submit()
    |> Map.get(:results, [])
    |> Enum.at(0)
  end

  @doc """
  Retrieve one document by its uid
  param type [String] the document type's name
  param uid [String] the uid to search
  param opts [Map] query options (ref, etc.)
  @return the document, or nil if not found
  """
  def documents(%{type: type, uid: uid}, opts) do
    everything_search_form(opts)
    |> SearchForm.set_query_predicates([Predicate.at("my." <> type <> ".uid", uid)])
    |> SearchForm.submit()
    |> Map.get(:results, [])
    |> Enum.at(0)
  end

  @doc """
  Retrieve multiple documents by their ids
  @param ids [String] the ids to fetch
  @param opts [map] query options (page, pageSize, ref, etc.)
  @return the documents, or [] if not found
  """
  def documents(%{ids: ids}, opts) do
    everything_search_form(opts)
    |> SearchForm.set_query_predicates([Predicate.where_in("document.id", ids)])
    |> SearchForm.submit()
    |> Map.get(:results, [])
  end

  def documents(%{tags: tags, type: type}, opts) do
    everything_search_form(opts)
    |> SearchForm.set_query_predicates([Predicate.at("document.tags", tags), Predicate.at("document.type", type)])
    |> SearchForm.submit()
    |> Map.get(:results, [])
  end

  def documents(%{type: type, latitude: latitude, longitude: longitude, radius: radius, location_api_id: api_id}, opts) do
    everything_search_form(opts)
    |> SearchForm.set_query_predicates([Predicate.near("my.#{type}.#{api_id}", latitude, longitude, radius), Predicate.at("document.type", type)])
    |> SearchForm.submit()
    |> Map.get(:results, [])
  end

  def documents(%{type: type}, opts) do
    everything_search_form(opts)
    |> SearchForm.set_query_predicates([Predicate.at("document.type", type)])
    |> SearchForm.submit()
    |> Map.get(:results, [])
  end

  def submit(%SearchForm{} = search_form), do: SearchForm.submit(search_form)

  @doc """
  Return the URL to display a given preview
  @param token [String] as received from Prismic server to identify the content to preview
  @return [String] the URL to redirect the user to
  """
  def preview_documents(token) do
    token = token |> URI.decode
    with {:ok, %{status_code: 200, body: body}} <- Prismic.HTTPClient.get(token),
         {:ok, json} = Poison.decode(body) do
        everything_search_form()
        |> SearchForm.set_query_predicates([Predicate.at("document.id", json["mainDocument"])])
        |> SearchForm.set_data_field(:ref, json["ref"])
        |> SearchForm.submit()
        |> Map.get(:results, [])
    else
        _ -> []
    end
  end

  defp everything_search_form(opts \\ %{}) do
    a = api(opts[:repo_url] || repo_url())
    ref = opts[:ref] || API.find_ref(a, "Master")

    a
    |> SearchForm.from_api()
    |> SearchForm.set_ref(ref)
  end
end
