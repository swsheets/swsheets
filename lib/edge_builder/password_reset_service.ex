defmodule EdgeBuilder.PasswordResetService do
  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Repo

  def start_reset(conn, user) do
    user = User.changeset(user, :password_reset, %{password_reset_token: Ecto.UUID.generate}) |> Repo.update

    EdgeBuilder.Mailer.send_email(to: user.email, template: :password_reset, username: user.username, password_reset_link: EdgeBuilder.Router.Helpers.password_reset_url(conn, :reset, %{token: user.password_reset_token}))
  end
end
