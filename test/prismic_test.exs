defmodule Prismic.Test do
  use ExUnit.Case

  alias Prismic.API

  describe "api/1" do
    test "sends request to repo url and initializes api struct" do
      {:ok, %API{}} = Prismic.api()
    end
  end

  describe "all/1" do
    test "submits everything form" do
      {:ok, documents} = Prismic.all()
      refute Enum.empty?(documents)
    end

  end

  describe "returns error tuple with non json repsonse" do
    setup do
      repo_url = Application.get_env(:prismic, :repo_url)
      Application.put_env(:prismic, :repo_url, "access_denied.cdn.prismic.io")
      on_exit :reset_repo_url, fn () ->
        Application.put_env(:prismic, :repo_url, repo_url)
      end
    end

    test "returns error tuple if getting error from prismic" do
      {:error, _error} = Prismic.all()
    end
  end

  describe "everything_search_form/1" do
    test "sets master ref by default" do
      {:ok, %{data: %{ref: ref}, api: %{refs: [%{ref: master_ref}]}}} = Prismic.everything_search_form()
      assert ref == master_ref
    end

    test "sets preview token as ref if one given" do
      {:ok, %{data: %{ref: ref}}} = Prismic.everything_search_form(%{preview_token: "yo"})
      assert ref == "yo"
    end
  end
end
