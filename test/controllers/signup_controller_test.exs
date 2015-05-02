defmodule EdgeBuilder.Controllers.SignupControllerTest do
  use EdgeBuilder.ControllerTest

  alias Fixtures.UserFixture
  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Repo
  import Ecto.Query, only: [from: 2]

  describe "welcome" do
    it "renders a login form" do
      conn = request(:get, "/welcome")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, "Username")
      assert String.contains?(conn.resp_body, "Password")
    end
    
    it "renders the new user form" do
      conn = request(:get, "/welcome")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, "Username")
      assert String.contains?(conn.resp_body, "Email")
      assert String.contains?(conn.resp_body, "Password")
    end
  end

  describe "signup" do
    it "creates a new user" do
      request(:post, "/signup", %{
        "user" => %{
          "email" => "test@example.com",
          "username" => "test",
          "password" => "my$good14password15is_verylong",
          "password_confirmation" => "my$good14password15is_verylong"
        }
      })

      user = Repo.one(from u in User, where: u.username == "test")

      assert !is_nil(user)
      assert user.email == "test@example.com"
      assert user.username == "test"
      assert {:ok, user} == User.authenticate(user.username, "my$good14password15is_verylong")
    end
  end


  describe "login" do
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
