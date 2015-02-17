defmodule EdgeBuilder.CharacterController do
  use Phoenix.Controller

  alias EdgeBuilder.Models.Character

  plug :action

  def edit(conn, %{"id" => id}) do
    render conn, "edit.html", character: Character.full_character(id)
  end

  def update(conn, params = %{"id" => id, "character" => character_params}) do
    changesets = List.flatten([
      character_changeset(id, character_params),
      talent_changesets(params["talents"])
    ])

    if Enum.all?(changesets, &(&1.valid?)) do
      changesets |> Enum.map(&EdgeBuilder.Repo.update/1)
      conn
        |> put_status(200)
        |> text "ok"
    else
      conn
        |> put_status(400)
        |> text "not okay"
    end
  end

  defp character_changeset(id, params) do
    Character.full_character(id)
      |> Character.changeset(params)
  end

  defp talent_changesets(params) when is_map(params) do
    params
      |> Map.values
      |> Enum.map(fn x ->
        EdgeBuilder.Repo.get(EdgeBuilder.Models.Talent, x["id"])
          |> EdgeBuilder.Models.Talent.changeset(x)
      end)
  end
  defp talent_changesets(_), do: []
end
