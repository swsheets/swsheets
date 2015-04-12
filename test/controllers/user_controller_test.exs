defmodule EdgeBuilder.Controllers.UserControllerTest do
  use EdgeBuilder.ControllerTest

  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Repo
  alias Helpers.FlokiExt
  import Ecto.Query, only: [from: 2]

  describe "new" do
    it "renders the new user form" do
      conn = request(:get, "/user/new")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, "Username")
      assert String.contains?(conn.resp_body, "Email")
      assert String.contains?(conn.resp_body, "Password")
    end
  end
end
