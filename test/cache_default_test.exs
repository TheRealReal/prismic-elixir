defmodule Prismic.Cache.DefaultTest do
  use ExUnit.Case, async: true
  alias Prismic.Cache

  setup do
    start_supervised(Cache.Default)
    :ok
  end

  test "sets values" do
    Cache.Default.set(:bacon, :eggs)
    assert Cache.Default.get(:bacon) == :eggs
  end

  test "expires based on ttl" do
    Cache.Default.set(:bacon, :eggs, 0)
    assert is_nil(Cache.Default.get(:bacon))
  end
end
