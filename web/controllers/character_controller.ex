defmodule EdgeBuilder.CharacterController do
  use Phoenix.Controller

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.Talent
  alias EdgeBuilder.Models.Attack
  alias EdgeBuilder.Models.CharacterSkill
  alias EdgeBuilder.Changemap
  alias EdgeBuilder.Repo

  plug :action

  def new(conn, _params) do
    render conn, "new.html",
      title: "New Character",
      character: %Character{} |> Character.changeset,
      talents: [%Talent{} |> Talent.changeset],
      attacks: [%Attack{} |> Attack.changeset],
      character_skills: CharacterSkill.add_missing_defaults([])
  end

  def create(conn, params = %{"character" => character_params}) do
    changemap = %{
      root: Character.changeset(%Character{}, character_params),
      talents: child_changesets(params["talents"], Talent),
      attacks: child_changesets(params["attacks"], Attack),
      character_skills: character_skill_changesets(params["skills"])
    }

    if Changemap.valid?(changemap) do
      changemap
        |> Changemap.apply

      conn
        |> put_status(200)
        |> text "ok"
    else
      conn
        |> put_status(400)
        |> text "not ok"
    end
  end

  def edit(conn, %{"id" => id}) do
    character = Repo.get(Character, id) |> Character.changeset

    render conn, "edit.html",
      title: "Editing #{Ecto.Changeset.get_field(character, :name)}",
      character: character,
      talents: Talent.for_character(id) |> Enum.map(&Talent.changeset/1),
      attacks: Attack.for_character(id) |> Enum.map(&Attack.changeset/1),
      character_skills: CharacterSkill.for_character(id) |> CharacterSkill.add_missing_defaults
  end

  def update(conn, params = %{"id" => id, "character" => character_params}) do
    changemap = %{
      root: Repo.get(Character, id) |> Character.changeset(character_params),
      talents: child_changesets(params["talents"], Talent),
      attacks: child_changesets(params["attacks"], Attack),
      character_skills: character_skill_changesets(params["skills"])
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

  defp child_changesets(params, child_model) when is_map(params) do
    params
      |> Map.values
      |> Enum.map(&(to_changeset(&1, child_model)))
  end
  defp child_changesets(_,_), do: []

  defp to_changeset(params = %{"id" => id}, model) when not is_nil(id), do: Repo.get(model, id) |> model.changeset(params)
  defp to_changeset(params, model), do: model.changeset(struct(model), params)

  defp character_skill_changesets(params) when is_map(params) do
    params
      |> Map.values
      |> Enum.map(&(Map.put(&1, "is_career", !is_nil(&1["is_career"]))))
      |> Enum.map(&(to_changeset(&1, CharacterSkill)))
      |> Enum.reject(&CharacterSkill.is_default_changeset?/1)
  end
  defp character_skill_changesets(_), do: []
end
