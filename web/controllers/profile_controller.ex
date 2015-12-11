defmodule EdgeBuilder.ProfileController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.FavoriteList
  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Models.Vehicle
  alias EdgeBuilder.Repo
  import Ecto.Query, only: [from: 2]

  plug Plug.Authentication, except: [:show]

  def show(conn, %{"id" => username}) do
    user = User.by_username(username)
    characters = Repo.all(from c in Character, where: c.user_id == ^user.id, order_by: [desc: c.updated_at])
    vehicles = Repo.all(from v in Vehicle, where: v.user_id == ^user.id, order_by: [desc: v.updated_at])

    render conn, :show,
      user: user,
      characters: characters,
      vehicles: vehicles
  end

  def my_creations(conn, _params) do
    user = Repo.get(User, current_user_id(conn))
    characters = Repo.all(from c in Character, where: c.user_id == ^user.id, order_by: [desc: c.updated_at])
    vehicles = Repo.all(from v in Vehicle, where: v.user_id == ^user.id, order_by: [desc: v.updated_at])

    render conn, :my_creations,
      user: user,
      characters: characters,
      vehicles: vehicles
  end

  def my_favorite_lists(conn, _params) do
    user = Repo.get(User, current_user_id(conn))
    favorite_lists = Repo.all(from f in FavoriteList, where: f.user_id == ^user.id, order_by: [asc: f.name], preload: [:characters, :vehicles])

    render conn, :my_favorite_lists,
      user: user,
      favorite_lists: favorite_lists
  end
end
