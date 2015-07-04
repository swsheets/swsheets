defmodule EdgeBuilder.API.CharacterController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.Character

  plug Plug.Authentication

  def update(conn, %{"id" => id, "character" => character_params}) do
    character = Character.full_character(id)

    if !is_owner?(conn, character) do
      put_status(conn, 403)
    else
      changes = Character.changeset(character, current_user_id(conn), character_params)

      if changes.valid? do
        Repo.update!(changes)

        put_status(conn, 200)
        |> json  %{ok: true}
      else
        put_status(conn, 400)
        |> json %{errors: map_errors(changes.errors)}
      end
    end
  end

  defp map_errors(errors) do
    Enum.reduce(errors, %{}, fn({field, message}, acc) ->
      Map.put(acc, field, message)
    end)
  end
end
