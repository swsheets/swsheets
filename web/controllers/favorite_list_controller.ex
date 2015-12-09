defmodule EdgeBuilder.FavoriteListController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.FavoriteList
  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Repo

  plug Plug.Authentication

  def add_character(conn, %{"name" => name, "character_id" => id}) do
    user = User.find_by_id current_user_id(conn)
    character = Repo.get(Character, id)
    list = User.find_or_create_favorite_list_by_name(user, name)
    FavoriteList.add_character(list, character)

    redirect conn, to: character_path(conn, :show, character)
  end
end
