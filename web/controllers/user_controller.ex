defmodule EdgeBuilder.UserController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Repo
  import Ecto.Query, only: [from: 2]

  plug Plug.Authentication, only: [:edit]
  plug :action

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"user" => user_params}) do
    user = User.changeset(%User{}, :create, user_params)
    EdgeBuilder.Repo.insert(user)

    redirect conn, to: "/"
  end

  def edit(conn, _params) do
    user = Repo.get(User, get_session(conn, :current_user_id)) |> User.changeset(:update)

    render conn, "edit.html", user: user
  end
end
