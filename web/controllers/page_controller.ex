defmodule EdgeBuilder.PageController do
  use EdgeBuilder.Web, :controller

  plug :action

  def index(conn, _params) do
    redirect conn, to: EdgeBuilder.Router.Helpers.character_path(conn, :index)
  end
end
