defmodule EdgeBuilder.ProfileController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Repo
  import Ecto.Query, only: [from: 2]

  plug :action

  def show(conn, %{"id" => username}) do
    user = User.by_username(username)
    render conn, :show, user: user
  end
end
