defmodule EdgeBuilder.SettingsController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Repo
  alias EdgeBuilder.ErrorHelpers
  alias Ecto.Changeset

  plug Plug.Authentication

  def edit(conn, _params) do
    user = Repo.get(User, get_session(conn, :current_user_id)) |> User.changeset(:update)

    render(conn, "edit.html", user: user)
  end

  def update(conn, %{"user" => user_params}) do
    user =
      Repo.get(User, get_session(conn, :current_user_id)) |> User.changeset(:update, user_params)

    if user.valid? do
      Repo.update!(user)
      render(conn, "edit.html", user: user, saved: true)
    else
      render(conn, :edit,
        user: user,
        errors: Changeset.traverse_errors(user, &ErrorHelpers.translate_error/1)
      )
    end
  end
end
