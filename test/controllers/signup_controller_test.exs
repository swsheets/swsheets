defmodule EdgeBuilder.Controllers.SignupControllerTest do
  use EdgeBuilder.ConnCase

  alias Factories.UserFactory
  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Repo
  alias Helpers.FlokiExt
  import Ecto.Query, only: [from: 2]

  describe "welcome" do
    it "renders a login form" do
      conn = build_conn() |> get("/welcome")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, "login[username]")
      assert String.contains?(conn.resp_body, "login[password]")
    end

    it "renders the new user form" do
      conn = build_conn() |> get("/welcome")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, "signup[username]")
      assert String.contains?(conn.resp_body, "signup[email]")
      assert String.contains?(conn.resp_body, "signup[password]")
      assert String.contains?(conn.resp_body, "signup[password_confirmation]")
    end
  end

  describe "signup" do
    it "creates a new user" do
      conn = build_conn() |> post("/signup", %{
        "signup" => %{
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
      assert is_redirect_to?(conn, "/")
      assert Plug.Conn.get_session(conn, :current_user_id) == user.id
      assert Plug.Conn.get_session(conn, :current_user_username) == user.username
    end

    it "renders an error if the username is already taken" do
      UserFactory.create_user!(username: "bobafett")

      conn = build_conn() |> post("/signup", %{
        "signup" => %{
          "email" => "test@example.com",
          "username" => "bobafett",
          "password" => "my$good14password15is_verylong",
          "password_confirmation" => "my$good14password15is_verylong"
        }
      })

      assert FlokiExt.element(conn, ".alert-danger") |> FlokiExt.text == "Username has already been taken"
      assert String.contains?(conn.resp_body, "test@example.com")
      assert String.contains?(conn.resp_body, "bobafett")
    end
  end

  describe "login" do
    it "logs the user in when they supply the correct password" do
      user = UserFactory.create_user!(password: "floopowder", password_confirmation: "floopowder")

      conn = build_conn() |> post("/login", %{
        "login" => %{
          "username" => user.username,
          "password" => "floopowder"
        }
      })

      assert conn.status == 302
      assert Plug.Conn.get_session(conn, :current_user_id) == user.id
      assert Plug.Conn.get_session(conn, :current_user_username) == user.username
    end

    it "displays an error message when the login's password doesn't match" do
      user = UserFactory.create_user!(password: "floopowder", password_confirmation: "floopowder")

      conn = build_conn() |> post("/login", %{
        "login" => %{
          "username" => user.username,
          "password" => "diagonally"
        }
      })

      assert FlokiExt.element(conn, ".alert-danger") |> FlokiExt.text == "No matching username and password could be found"
    end

    it "displays an error message when the login's username doesn't exist" do
      conn = build_conn() |> post("/login", %{
        "login" => %{
          "username" => "harry potter",
          "password" => "diagonally"
        }
      })

      assert FlokiExt.element(conn, ".alert-danger") |> FlokiExt.text == "No matching username and password could be found"
    end
  end

  describe "logout" do
    it "logs out the user" do
      conn = build_conn() |> authenticate_as(UserFactory.default_user) |> post("/logout")

      assert is_redirect_to?(conn, "/")
      assert is_nil(Plug.Conn.get_session(conn, :current_user_id))
      assert is_nil(Plug.Conn.get_session(conn, :current_user_username))
    end
  end
end
