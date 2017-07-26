defmodule EdgeBuilder.SignupController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.User

  def welcome(conn, _params) do
    render conn, "welcome.html"
  end

  def login(conn, %{"login" => %{"username" => username, "password" => password}}) do
    case User.authenticate(username, password) do
      {:ok, user} -> 
        conn
        |> set_current_user(user)
        |> redirect(to: "/")
      _ ->
        conn
        |> delete_session(:current_user_id)
        |> render("welcome.html", login_error: true)
    end
  end

  def signup(conn, %{"signup" => user_params}) do
    case User.changeset(%User{}, :create, user_params) |> EdgeBuilder.Repo.insert do
      {:ok, user} ->
        conn
        |> set_current_user(user)
        |> redirect(to: "/")
      {:error, changeset} ->
        render conn, "welcome.html",
          errors:          changeset.errors,
          signup_username: user_params["username"],
          signup_email:    user_params["email"]
    end
  end

  def logout(conn, _params) do
    conn
    |> delete_session(:current_user_id)
    |> delete_session(:current_user_username)
    |> redirect(to: "/")
  end
end
