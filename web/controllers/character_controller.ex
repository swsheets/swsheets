defmodule EdgeBuilder.CharacterController do
  use Phoenix.Controller

  alias EdgeBuilder.Models.Character
  import EdgeBuilder.Router.Helpers

  plug :action

  def edit(conn, %{"id" => id}) do
    render conn, "edit.html", character: Character.full_character(id)
  end

  def update(conn, %{"id" => id, "character" => params}) do
    changeset = Character.full_character(id)
      |> Character.changeset(params)

    if changeset.valid? do
      EdgeBuilder.Repo.update(changeset)
      conn
        |> put_status(200)
        |> text "ok"
    else
      conn
        |> put_status(400)
        |> text "not okay"
    end
  end
end
