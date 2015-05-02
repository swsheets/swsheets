defmodule EdgeBuilder.SettingsController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Repo

  plug Plug.Authentication
  plug :action

  def edit(conn, _params) do
    user = Repo.get(User, get_session(conn, :current_user_id)) |> User.changeset(:update)

    render conn, "edit.html", user: user
  end
end
