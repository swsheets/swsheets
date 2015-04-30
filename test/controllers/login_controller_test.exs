defmodule EdgeBuilder.Controllers.LoginControllerTest do
  use EdgeBuilder.ControllerTest

  alias Fixtures.UserFixture

  describe "new" do
    it "renders a login form" do
      conn = request(:get, "/login")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, "Username")
      assert String.contains?(conn.resp_body, "Password")
    end
  end

  describe "create" do
    it "logs the user in when they supply the correct password" do
      user = UserFixture.create_user(password: "floopowder", password_confirmation: "floopowder")

      conn = request(:post, "/login", %{
        "login" => %{
          "username" => user.username,
          "password" => "floopowder"
        }
      })

      assert conn.status == 302
      assert Plug.Conn.get_session(conn, :current_user_id) == user.id
    end
  end
end
