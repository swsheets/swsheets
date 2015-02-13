defmodule EdgeBuilder.CharacterController do
  use Phoenix.Controller

  alias EdgeBuilder.Models.Character

  plug :action

  def edit(conn, %{"id" => id}) do
    render conn, "edit.html", character: Character.full_character(id)
  end
end
