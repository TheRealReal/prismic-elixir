defmodule Prismic.HTTPClient do
  #TODO: define response struct, the requests
  # are still coupled to poison responses
  # ( status_code, and body keys )

  @type headers :: [{binary, binary}] | %{binary => binary}
  @type data :: %{binary => any}

  @callback get(binary, headers, Keyword.t) :: {:ok, Map.t} | {:error, any}
  @callback post(binary, data, headers, Keyword.t) :: {:ok, Map.t} | {:error, any}
  def http_client_module do
    Application.get_env(:prismic, :http_client_module) || Prismic.HTTPClient.Default
  end

  def get(url, headers \\ [], options \\ []) do
    http_client_module().get(url, headers, options)
  end

  def post(url, data, headers \\ [], options \\ []) do
    http_client_module().post(url, data, headers, options)
  end
end

defmodule Prismic.HTTPClient.Default do
  @behaviour Prismic.HTTPClient
# TODO: wrap in code.ensure_loaded when HTTPoison is an optional
# dependency
  def get(url, headers, options) do
    HTTPoison.get(url, headers, options)
  end

  def post(url, data, headers, options) do
    HTTPoison.post(url, data, headers, options)
  end
end
