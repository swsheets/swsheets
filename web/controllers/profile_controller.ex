defmodule EdgeBuilder.ProfileController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Repo

  plug Plug.Authentication, except: [:show]

  def show(conn, %{"id" => username}) do
    user = User.by_username(username)
    characters = EdgeBuilder.Repositories.CharacterRepo.all_for_user(user.id)
    vehicles = EdgeBuilder.Repositories.VehicleRepo.all_for_user(user.id)


    render conn, :show,
      user: user,
      characters: characters,
      vehicles: vehicles
  end

  def my_creations(conn, _params) do
    user = Repo.get(User, current_user_id(conn))
    characters = EdgeBuilder.Repositories.CharacterRepo.all_for_user(user.id)
    vehicles = EdgeBuilder.Repositories.VehicleRepo.all_for_user(user.id)


    render conn, :my_creations,
      user: user,
      characters: characters,
      vehicles: vehicles
  end
end
