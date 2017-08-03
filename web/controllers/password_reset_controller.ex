defmodule EdgeBuilder.PasswordResetController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Repo
  import Ecto.Query, only: [from: 2]

  def request(conn, _params) do
    render conn, :request
  end

  def submit_request(conn, %{"password_reset" => params}) do
    user = Repo.one(from u in User, where: fragment("upper(email)") == ^String.upcase(params["email"]))

    if user, do: EdgeBuilder.PasswordResetService.start_reset(conn, user)

    render conn, :request, after_request: true
  end

  def reset(conn, %{"token" => token}) do
    case find_user_by_token(token) do
      nil -> render_404(conn)
      _ -> render conn, :reset, token: token
    end
  end

  def submit_reset(conn, %{"password_reset" => params}) do
    case find_user_by_token(params["token"]) do
      nil -> render_404(conn)
      user ->
        user = User.changeset(user, :password_reset, Map.put(params, "password_reset_token", nil))
        if user.valid? do
          user = Repo.update!(user)
          conn
          |> set_current_user(user)
          |> put_flash(:has_reset_password, true)
          |> redirect(to: "/")
        else
          render conn, :reset, token: params["token"], errors: user.errors
        end
    end
  end

  defp find_user_by_token(token) do
    case Ecto.UUID.cast(token) do
      :error -> nil
      _ -> Repo.one(from u in User, where: u.password_reset_token == ^token)
    end
  end
end
