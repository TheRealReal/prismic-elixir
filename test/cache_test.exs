defmodule Prismic.CacheTest do
  use ExUnit.Case

  setup do
    og_env = Application.get_env(:prismic, :cache_module)
    Application.put_env(:prismic, :cache_module, Prismic.Cache.Echo)
    on_exit fn -> Application.put_env(:prismic, :cache_module, og_env) end
  end

  describe "get/1" do
    import Prismic.Cache, only: [get: 1]
    test "delegates to configured cache" do
      assert get("foo") == "got foo"
    end
  end

  describe "set/2" do
    import Prismic.Cache, only: [set: 2]
    test "delegates to configured cache" do
      assert set("foo", "bar") == "set foo to bar"
    end
  end

  describe "get_or_store/2" do
    import Prismic.Cache, only: [get_or_store: 2]
    test "delegates to configured cache" do
      assert get_or_store("foo", fn -> "bar" end) == "got_or_stored foo to bar"
    end
  end
end

defmodule Prismic.Cache.Echo do
  @moduledoc "fake cache for testing"
  @behaviour Prismic.Cache

  def get(key), do: "got " <> key
  def set(key, value), do: "set " <> key <> " to " <> value
  def get_or_store(key, fun), do: "got_or_stored " <> key <> " to " <> fun.()
end
