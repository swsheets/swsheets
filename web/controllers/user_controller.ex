defmodule EdgeBuilder.UserController do
  use EdgeBuilder.Web, :controller

  plug :action

  def new(conn, _params) do
    render conn, "new.html"
  end
end
