defmodule EdgeBuilder.SharedView do
  use EdgeBuilder.Web, :view

  alias EdgeBuilder.Models.FavoriteList

  def logged_in?(conn) do
    !is_nil(Plug.Conn.get_session(conn, :current_user_id))
  end

  def user_favorite_lists(conn) do
    if user_id = Plug.Conn.get_session(conn, :current_user_id) do
      FavoriteList.all_by_user_id(user_id)
    end
  end
end
