defmodule EdgeBuilder.Controllers.PasswordResetControllerTest do
  use EdgeBuilder.ConnCase

  import Mock
  alias Factories.UserFactory
  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Repo
  alias Helpers.FlokiExt

  describe "request" do
    it "renders a email address form" do
      conn = build_conn() |> get("/forgot-password")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, "password_reset[email]")
    end
  end

  describe "submit_request" do
    it "emails a password reset link" do
      user = UserFactory.default_user

      with_mock EdgeBuilder.Mailer, [send_email: fn(_) -> nil end] do
        build_conn() |> post("/forgot-password", %{"password_reset" => %{"email" => user.email}})

        user = Repo.get(User, user.id)

        assert !is_nil(user.password_reset_token)
        assert called EdgeBuilder.Mailer.send_email(
          to: user.email,
          template: :password_reset,
          username: user.username,
          password_reset_link: "http://localhost:4001/password-reset?token=#{user.password_reset_token}"
        )
      end
    end

    it "emails a password reset link to the original email address even when the capitalization of the form is different" do
      user = UserFactory.default_user

      with_mock EdgeBuilder.Mailer, [send_email: fn(_) -> nil end] do
        build_conn() |> post("/forgot-password", %{"password_reset" => %{"email" => String.upcase(user.email)}})

        user = Repo.get(User, user.id)

        assert !is_nil(user.password_reset_token)
        assert called EdgeBuilder.Mailer.send_email(
          to: user.email,
          template: :password_reset,
          username: user.username,
          password_reset_link: "http://localhost:4001/password-reset?token=#{user.password_reset_token}"
        )
      end
    end

    it "shows a success message" do
      conn = build_conn() |> post("/forgot-password", %{"password_reset" => %{"email" => UserFactory.default_user.email}})
      assert String.contains?(conn.resp_body, "Instructions have been sent to that email address. If you do not see an email within a few minutes, double-check that you entered the correct email address.")
    end

    it "shows a success message even when the email address doesn't exist" do
      conn = build_conn() |> post("/forgot-password", %{"password_reset" => %{"email" => "TOTALLY MADE UP EMAIL"}})
      assert String.contains?(conn.resp_body, "Instructions have been sent to that email address. If you do not see an email within a few minutes, double-check that you entered the correct email address.")
    end
  end

  describe "reset" do
    it "loads the form on a recognized token" do
      user = UserFactory.create_user! |> UserFactory.add_password_reset_token

      conn = build_conn() |> get("/password-reset?token=#{user.password_reset_token}")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, "password_reset[password]")
      assert String.contains?(conn.resp_body, "password_reset[password_confirmation]")
      assert String.contains?(conn.resp_body, user.password_reset_token)
    end

    it "rejects an unrecognized token" do
      conn = build_conn() |> get("/password-reset?token=a_made_up_token")

      assert conn.status == 404
    end
  end

  describe "submit_reset" do
    it "resets the password and logs in" do
      user = UserFactory.create_user! |> UserFactory.add_password_reset_token

      conn = build_conn() |> post("/password-reset", %{"password_reset" => %{"password" => "asdasdasdasd", "password_confirmation" => "asdasdasdasd", "token" => user.password_reset_token}})

      assert {:ok, _} = User.authenticate(user.username, "asdasdasdasd")
      user = Repo.get(User, user.id)
      assert is_nil(user.password_reset_token)

      assert Plug.Conn.get_session(conn, :current_user_id) == user.id
      assert Plug.Conn.get_session(conn, :current_user_username) == user.username
    end

    it "redirects to the welcome page with a notice about resetting the password" do
      user = UserFactory.create_user! |> UserFactory.add_password_reset_token

      conn = build_conn() |> post("/password-reset", %{"password_reset" => %{"password" => "asdasdasdasd", "password_confirmation" => "asdasdasdasd", "token" => user.password_reset_token}})

      assert is_redirect_to?(conn, "/")
      assert Phoenix.Controller.get_flash(conn, :has_reset_password)
    end

    it "renders a 404 if the token is not found" do
      conn = build_conn() |> post("/password-reset", %{"password_reset" => %{"password" => "asdasdasdasd", "password_confirmation" => "asdasdasdasd", "token" => "NOT A REAL TOKEN"}})

      assert conn.status == 404
    end

    it "renders an error message if the password does not match the confirmation" do
      user = UserFactory.create_user! |> UserFactory.add_password_reset_token

      conn = build_conn() |> post("/password-reset", %{"password_reset" => %{"password" => "asdasdasdasd", "password_confirmation" => "foo", "token" => user.password_reset_token}})

      assert FlokiExt.element(conn, ".alert-danger") |> FlokiExt.text |> String.contains?("Password does not match the confirmation")
      assert String.contains?(conn.resp_body, user.password_reset_token)
    end
  end
end
