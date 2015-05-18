defmodule EdgeBuilder.PasswordResetController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Repo
  import Ecto.Query, only: [from: 2]

  plug :action

  def request(conn, _params) do
    render conn, :request
  end

  def submit_request(conn, %{"password_reset" => params}) do
    user = Repo.one(from u in User, where: u.email == ^params["email"])

    if user, do: EdgeBuilder.PasswordResetService.start_reset(conn, user)

    render conn, :request, after_request: true
  end
end
