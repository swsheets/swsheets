defmodule EdgeBuilder.CharacterController do
  use Phoenix.Controller

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Changemap

  plug :action

  def edit(conn, %{"id" => id}) do
    render conn, "edit.html", character: Character.full_character(id)
  end

  def update(conn, params = %{"id" => id, "character" => character_params}) do
    changemap = %{
      root: character_changeset(id, character_params),
      talents: child_changesets(params["talents"], EdgeBuilder.Models.Talent, id),
      attacks: child_changesets(params["attacks"], EdgeBuilder.Models.Attack, id)
    }

    if Changemap.valid?(changemap) do
      changemap
        |> Changemap.apply
        |> Changemap.delete_missing

      conn
        |> put_status(200)
        |> text "ok"
    else
      conn
        |> put_status(400)
        |> text "not ok"
    end
  end

  defp character_changeset(id, params) do
    Character.full_character(id)
      |> Character.changeset(params)
  end

  defp child_changesets(params, child_model, character_id) when is_map(params) do
    params
      |> Map.values
      |> Enum.map(&(Map.put(&1, "character_id", character_id)))
      |> Enum.map(fn child_params ->
        case child_params do
          %{"id" => id} -> EdgeBuilder.Repo.get(child_model, id)
          _ -> struct(child_model)
        end |> child_model.changeset(child_params)
      end)
  end
  defp child_changesets(_,_,_), do: []
end
