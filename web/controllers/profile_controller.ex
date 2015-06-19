defmodule EdgeBuilder.ProfileController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Models.Vehicle
  alias EdgeBuilder.Repo
  import Ecto.Query, only: [from: 2]

  plug Plug.Authentication, except: [:show]
  plug :action

  def show(conn, %{"id" => username}) do
    user = User.by_username(username)
    characters = Repo.all(from c in Character, where: c.user_id == ^user.id, order_by: [desc: c.updated_at])

    render conn, :show,
      user: user,
      characters: characters
  end

  def my_content(conn, _params) do
    user = Repo.get(User, current_user_id(conn))
    characters = Repo.all(from c in Character, where: c.user_id == ^user.id, order_by: [desc: c.updated_at])
    vehicles = Repo.all(from v in Vehicle, where: v.user_id == ^user.id, order_by: [desc: v.updated_at])

    render conn, :my_content,
      user: user,
      characters: characters,
      vehicles: vehicles
  end
end
