defmodule EdgeBuilder.ProfileController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Repo
  import Ecto.Query, only: [from: 2]

  plug :action

  def show(conn, %{"id" => username}) do
    user = User.by_username(username)

    render conn, :show,
      header: EdgeBuilder.ProfileView.render("_header.html"),
      user: user,
      character_count: Repo.one(from c in Character,
        where: c.user_id == ^user.id,
        select: count(c.id)
      )
  end
end
