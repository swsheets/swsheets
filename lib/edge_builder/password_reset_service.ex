defmodule EdgeBuilder.PasswordResetService do
  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Repo

  def start_reset(conn, user) do
    user = User.changeset(user, :password_reset, %{password_reset_token: Ecto.UUID.generate}) |> Repo.update

    EdgeBuilder.Mailer.send_email(
      to: user.email,
      template: :password_reset,
      username: user.username,
      password_reset_link: Application.get_env(:edge_builder, :application_base_url) <> EdgeBuilder.Router.Helpers.password_reset_path(conn, :reset, %{token: user.password_reset_token})
    )
  end
end
