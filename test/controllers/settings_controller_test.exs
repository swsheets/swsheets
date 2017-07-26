defmodule EdgeBuilder.Controllers.SettingsControllerTest do
  use EdgeBuilder.ConnCase

  alias EdgeBuilder.Models.User
  alias Factories.UserFactory
  alias Helpers.FlokiExt

  describe "edit" do
    it "displays your user information" do
      user = UserFactory.default_user

      conn = build_conn() |> authenticate_as(user) |> get("/user/edit")

      assert FlokiExt.find(conn.resp_body, "#email") |> FlokiExt.attribute("value") == user.email
      assert String.contains?(conn.resp_body, user.username)
    end

    it "requires authentication" do
      conn = build_conn() |> get("/user/edit")

      assert is_redirect_to?(conn, "/welcome")
    end
  end

  describe "update" do
    it "updates your email address" do
      user = UserFactory.create_user!(email: "tom@example.com")

      conn = build_conn() |> authenticate_as(user) |> put("/user", %{"user" => %{"email" => "bruce@example.com"}})

      user = EdgeBuilder.Repo.get(User, user.id)

      assert user.email == "bruce@example.com"
      assert FlokiExt.element(conn, ".alert-success") |> FlokiExt.text == "Your settings have been updated"
    end

    it "updates your password" do
      user = UserFactory.create_user!(password: "thisismypassword", password_confirmation: "thisismypassword")

      build_conn()
      |> authenticate_as(user)
      |> put("/user", %{"user" =>
        %{"password" => "asdasdasdasd",
          "password_confirmation" => "asdasdasdasd"
        }})

      assert {:ok, _} = User.authenticate(user.username, "asdasdasdasd")
    end

    it "re-renders the page with errors if there are errors" do
      conn = build_conn()
      |> authenticate_as(UserFactory.default_user)
      |> put("/user", %{"user" =>
        %{"email" => "bruceatexample.com",
          "password" => "asdasdasdasd",
          "password_confirmation" => "asdasdasd123"
        }})

      assert FlokiExt.element(conn, ".alert-danger") |> FlokiExt.text |> String.contains?("Email must be a valid email address")
      assert FlokiExt.element(conn, ".alert-danger") |> FlokiExt.text |> String.contains?("Password does not match the confirmation")
    end
  end
end
