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
      attacks: child_changesets(params["attacks"], EdgeBuilder.Models.Attack, id),
      character_skills: character_skill_changesets(params["skills"], id)
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

  # I suspect I'll eventually get rid of this (and Character.full_character) when I have a unified model interface for actions on this controller
  defp character_changeset(id, params) do
    Character.full_character(id)
      |> Character.changeset(params)
  end

  defp character_skill_changesets(params, character_id) when is_map(params) do
    params
      |> Map.values
      |> Enum.map(&(Map.put(&1, "character_id", character_id)))
      |> Enum.map(&(Map.put(&1, "is_career", !is_nil(&1["is_career"]))))
      |> Enum.map(&(to_changeset(&1, EdgeBuilder.Models.CharacterSkill)))
      |> Enum.reject(&matches_default_character_skill/1)
  end
  defp character_skill_changesets(_, _), do: []

  defp child_changesets(params, child_model, character_id) when is_map(params) do
    params
      |> Map.values
      |> Enum.map(&(Map.put(&1, "character_id", character_id)))
      |> Enum.map(&(to_changeset(&1, child_model)))
  end
  defp child_changesets(_,_,_), do: []

  defp matches_default_character_skill(changeset) do
    default = %EdgeBuilder.Models.CharacterSkill{}

    is_nil(changeset.model.id)
      && Enum.all?([:rank, :is_career], fn field ->
        Ecto.Changeset.get_field(changeset, field) == Map.fetch!(default, field)
      end)
  end

  defp to_changeset(params = %{"id" => id}, model), do: EdgeBuilder.Repo.get(model, id) |> model.changeset(params)
  defp to_changeset(params, model), do: model.changeset(struct(model), params)
end
