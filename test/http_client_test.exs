defmodule Prismic.HTTPClientTest do
  use ExUnit.Case

  setup do
    og_env = Application.get_env(:prismic, :http_client_module)
    Application.put_env(:prismic, :http_client_module, Prismic.HTTPClient.Echo)
    on_exit(fn -> Application.put_env(:prismic, :http_client_module, og_env) end)
  end

  @moduledoc """
  Fake httpclient is set in test config
  """
  describe "get/1" do
    import Prismic.HTTPClient, only: [get: 3]

    test "delegates to configured client" do
      assert get("foo", "bar", "baz") == %{
               url: "foo",
               data: "",
               headers: "bar",
               options: "baz"
             }
    end
  end

  describe "set/2" do
    import Prismic.HTTPClient, only: [post: 4]

    test "delegates to configured client" do
      assert post("foo", "bar", "baz", "boz?") == %{
               url: "foo",
               data: "bar",
               headers: "baz",
               options: "boz?"
             }
    end
  end
end

defmodule Prismic.HTTPClient.Echo do
  @behaviour Prismic.HTTPClient

  def get(url, headers, options) do
    %{url: url, headers: headers, options: options}
  end

  def post(url, data, headers, options) do
    %{url: url, data: data, headers: headers, options: options}
  end

  def request(_method, url, data, headers, options) do
    %{url: url, data: data, headers: headers, options: options}
  end
end
