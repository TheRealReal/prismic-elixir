defmodule Prismic.APITest do
  use ExUnit.Case

  alias Prismic.{API, Ref}

  describe "new/2" do
    #TODO: test with bypass or after http client injection ( inject fake http client)
    test "hits provided url, returns a parsed api" do
    end

    test "can return error tuple" do
    end
  end

  describe "find_ref/2" do
    import API, only: [find_ref: 2]
    test "finds a ref with the given label" do
      ref = %Ref{label: "bacon", ref: "egg"}
      api = %API{refs: [ref]}

      assert find_ref(api, "bacon") == ref
    end

    test "can return nil" do
      api = %API{refs: []}
      assert is_nil(find_ref(api, "bacon"))
    end
  end
end
