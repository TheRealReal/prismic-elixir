defmodule Prismic.HTTPClient do
  # TODO: define response struct, the requests
  # are still coupled to poison responses
  # ( status_code, and body keys )

  @type headers :: [{binary, binary}] | %{binary => binary}
  @type data :: %{binary => any}

  @callback get(binary, headers, Keyword.t()) :: {:ok, Map.t()} | {:error, any}
  @callback post(binary, data, headers, Keyword.t()) :: {:ok, Map.t()} | {:error, any}
  @callback request(atom, binary, data, headers, Keyword.t()) :: {:ok, Map.t()} | {:error, any}
  def http_client_module do
    Application.get_env(:prismic, :http_client_module) || Prismic.HTTPClient.Default
  end

  def get(url, headers \\ [], options \\ []) do
    request(:get, url, "", headers, options)
  end

  def post(url, data, headers \\ [], options \\ []) do
    request(:post, url, data, headers, options)
  end

  def request(method, url, data, headers \\ [], options \\ []) do
    telemetry_metadata = %{http: %{method: method, url: url}}

    :telemetry.span([:prismic, :request], telemetry_metadata, fn ->
      http_result = http_client_module().request(method, url, data, headers, options)

      {http_result, update_telemetry_metadata(telemetry_metadata, http_result)}
    end)
  end

  defp update_telemetry_metadata(
         %{http: %{url: url, method: method}} = telemetry_metadata,
         http_result
       ) do
    http_result_metadata = extract_http_result_metadata(http_result)

    Map.merge(telemetry_metadata, %{
      status: http_result_metadata[:status],
      http: %{
        method: method,
        status_code: http_result_metadata[:status_code],
        url: url
      }
    })
  end

  defp extract_http_result_metadata(http_result) do
    case http_result do
      {:ok, %{status_code: status_code}} when status_code in 200..299 ->
        %{status: :ok, status_code: status_code}

      {_, %{status_code: status_code}} ->
        %{status: :error, status_code: status_code}

      _ ->
        %{status: :error}
    end
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

  def request(method, url, data, headers, options) do
    HTTPoison.request(method, url, data, headers, options)
  end
end
