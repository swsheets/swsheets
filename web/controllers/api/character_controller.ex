defmodule EdgeBuilder.API.CharacterController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Repositories.CharacterRepo

  plug Plug.Authentication

  def update(conn, %{"id" => id, "character" => character_params}) do
    character = CharacterRepo.full_character(id)

    if !is_owner?(conn, character) do
      put_status(conn, 403)
    else
      changes = Character.changeset(character, current_user_id(conn), character_params)

      case EdgeBuilder.Repo.update(changes) do
        {:ok, _} ->
          put_status(conn, 200)
          |> json(%{ok: true})
        {:error, changeset} ->
          put_status(conn, 400)
          |> json(%{errors: map_errors(changeset.errors)})
      end
    end
  end

  defp map_errors(errors) do
    Enum.reduce(errors, %{}, fn({field, {message, _}}, acc) ->
      Map.put(acc, field, message)
    end)
  end
end
