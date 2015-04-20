defmodule EdgeBuilder.UserController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.User

  plug :action

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"user" => user_params}) do
    user = User.changeset(%User{}, user_params)
    EdgeBuilder.Repo.insert(user)

    redirect conn, to: "/"
  end
end
