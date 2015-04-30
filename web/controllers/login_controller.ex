defmodule EdgeBuilder.LoginController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.User
  plug :action

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"login" => %{"username" => username, "password" => password}}) do
    case User.authenticate(username, password) do
      {:ok, user} -> 
        conn
          |> put_session(:current_user_id, user.id)
          |> redirect to: "/"
      _ ->
        conn
          |> redirect to: EdgeBuilder.Router.Helpers.login_path(:new)
    end
  end
end
