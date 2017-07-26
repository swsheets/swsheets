defmodule EdgeBuilder.ProfileController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Models.Vehicle
  alias EdgeBuilder.Repo
  import Ecto.Query, only: [from: 2]

  plug Plug.Authentication, except: [:show]

  def show(conn, %{"id" => username}) do
    user = User.by_username(username)
    characters = Repo.all(from c in Character, where: c.user_id == ^user.id, order_by: [desc: c.updated_at]) |> Enum.map(&Character.set_permalink/1)
    vehicles = Repo.all(from v in Vehicle, where: v.user_id == ^user.id, order_by: [desc: v.updated_at]) |> Enum.map(&Vehicle.set_permalink/1)


    render conn, :show,
      user: user,
      characters: characters,
      vehicles: vehicles
  end

  def my_creations(conn, _params) do
    user = Repo.get(User, current_user_id(conn))
    characters = Repo.all(from c in Character, where: c.user_id == ^user.id, order_by: [desc: c.updated_at]) |> Enum.map(&Character.set_permalink/1)
    vehicles = Repo.all(from v in Vehicle, where: v.user_id == ^user.id, order_by: [desc: v.updated_at]) |> Enum.map(&Vehicle.set_permalink/1)


    render conn, :my_creations,
      user: user,
      characters: characters,
      vehicles: vehicles
  end
end
