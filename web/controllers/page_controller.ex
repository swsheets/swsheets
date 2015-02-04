defmodule EdgeBuilder.PageController do
  use Phoenix.Controller

  plug :action

  def index(conn, _params) do
    render conn, "index.html"
  end

  def reference(conn, _params) do
    render conn, "reference.html"
  end
end
