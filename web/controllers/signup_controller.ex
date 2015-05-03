defmodule EdgeBuilder.SignupController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.User
  plug :action

  def welcome(conn, _params) do
    render conn, "welcome.html"
  end

  def login(conn, %{"login" => %{"username" => username, "password" => password}}) do
    case User.authenticate(username, password) do
      {:ok, user} -> 
        conn
          |> put_session(:current_user_id, user.id)
          |> redirect to: "/"
      _ ->
        conn
          |> redirect to: EdgeBuilder.Router.Helpers.signup_path(:welcome)
    end
  end

  def signup(conn, %{"signup" => user_params}) do
    user = User.changeset(%User{}, :create, user_params)

    if user.valid? do
      EdgeBuilder.Repo.insert(user)

      redirect conn, to: "/"
    else
      render conn, "welcome.html",
        errors:          user.errors,
        signup_username: user_params["username"],
        signup_email:    user_params["email"]
    end
  end
end
