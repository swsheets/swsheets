defmodule EdgeBuilder.LayoutView do
  use EdgeBuilder.Web, :view

  def title_or_default(title) when is_nil(title), do: title_or_default("")
  def title_or_default(title) do
    case String.length(title) do
      0 -> application_name()
      _ -> "#{title} | #{application_name()}"
    end
  end

  def logged_in?(conn) do
    !is_nil(Plug.Conn.get_session(conn, :current_user_id))
  end

  def username(conn) do
    Plug.Conn.get_session(conn, :current_user_username)
  end
end
