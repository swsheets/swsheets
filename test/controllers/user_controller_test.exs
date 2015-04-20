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

  describe "create" do
    it "creates a new user" do
      request(:post, "/user", %{
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
      assert User.password_matches?(user, "my$good14password15is_verylong")
    end
  end
end
