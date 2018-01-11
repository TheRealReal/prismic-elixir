defmodule Prismic.Test do
  use ExUnit.Case

  alias Prismic.API
  # import Plug.Conn, only: [resp: 3]
  # @api Prismic.Factory.build(:api)
  # setup do
  #   bypass = Prismic.Bypass.open
  #   json = @api |> Poison.encode!
  #   Bypass.expect bypass, "GET", "/", fn conn ->
  #     resp(conn, 200, json)
  #     |> IO.inspect
  #   end
  #   :ok
  # end

  describe "api/1" do
    test "sends request to repo url and initializes api struct" do
      %API{} = Prismic.api()
    end
  end

  describe "all/1" do
    test "submits everything form" do
      Prismic.all()
    end
  end
end
