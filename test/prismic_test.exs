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
end
