defmodule EdgeBuilder.Controllers.PasswordResetControllerTest do
  use EdgeBuilder.ControllerTest

  import Mock
  alias Factories.UserFactory
  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Repo

  describe "request" do
    it "renders a email address form" do
      conn = request(:get, "/password-reset")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, "password_reset[email]")
    end
  end

  describe "submit_request" do
    it "emails a password reset link" do
      user = UserFactory.default_user

      with_mock EdgeBuilder.Mailer, [send_email: fn(_) -> nil end] do
        request(:post, "/password-reset", %{"password_reset" => %{"email" => user.email}})

        user = Repo.get(User, user.id)

        assert !is_nil(user.password_reset_token)
        assert called EdgeBuilder.Mailer.send_email(
          to: user.email,
          template: :password_reset,
          username: user.username,
          password_reset_link: "http://localhost:4001/password-reset/reset?token=#{user.password_reset_token}"
        )
      end
    end
  end
end
