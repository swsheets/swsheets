defmodule EdgeBuilder.ProfileController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Repo
  import Ecto.Query, only: [from: 2]

  plug :action

  def show(conn, %{"id" => username}) do
    user = User.by_username(username)
    characters = Repo.all(from c in Character, where: c.user_id == ^user.id, order_by: [desc: c.inserted_at])

    render conn, :show,
      user: user,
      characters: characters
  end
end
