defmodule EdgeBuilder.PageController do
  use Phoenix.Controller

  plug :action

  def index(conn, _params) do
    redirect conn, to: EdgeBuilder.Router.Helpers.character_path(conn, :index)
  end
end
