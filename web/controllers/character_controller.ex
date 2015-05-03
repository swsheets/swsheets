defmodule EdgeBuilder.CharacterController do
  use EdgeBuilder.Web, :controller

  import EdgeBuilder.Router.Helpers
  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.Talent
  alias EdgeBuilder.Models.Attack
  alias EdgeBuilder.Models.CharacterSkill
  alias EdgeBuilder.Changemap

  plug Plug.Authentication, except: [:show, :index]
  plug :action

  def new(conn, _params) do
    render_new conn
  end

  def create(conn, params = %{"character" => character_params}) do
    changemap = %{
      root: Character.changeset(%Character{}, character_params),
      talents: child_changesets(params["talents"], Talent),
      attacks: child_changesets(params["attacks"], Attack),
      character_skills: character_skill_changesets(params["skills"])
    }

    if Changemap.valid?(changemap) do
      changes = Changemap.apply(changemap)

      redirect conn, to: character_path(conn, :show, changes.root.id)
    else
      render_new conn,
        character: changemap.root,
        talents: changemap.talents,
        attacks: changemap.attacks,
        character_skills: changemap.character_skills,
        errors: changemap.root.errors
    end
  end

  def index(conn, _params) do
    render conn, "index.html",
      title: "My Characters",
      header: EdgeBuilder.CharacterView.render("_index_header.html"),
      characters: EdgeBuilder.Repo.all(Character)
  end

  def show(conn, %{"id" => id}) do
    character = Character.full_character(id)

    render conn, "show.html",
      header: EdgeBuilder.CharacterView.render("_show_header.html"),
      footer: EdgeBuilder.CharacterView.render("footer.html"),
      title: character.name,
      character: character |> Character.changeset,
      talents: character.talents |> Enum.map(&Talent.changeset/1),
      attacks: character.attacks |> Enum.map(&Attack.changeset/1),
      character_skills: character.character_skills |> CharacterSkill.add_missing_defaults
  end

  def edit(conn, %{"id" => id}) do
    character = Character.full_character(id)

    render_edit conn,
      character: character |> Character.changeset,
      talents: (if Enum.empty?(character.talents), do: [%Talent{}], else: character.talents) |> Enum.map(&Talent.changeset/1),
      attacks: (if Enum.empty?(character.attacks), do: [%Attack{}], else: character.attacks) |> Enum.map(&Attack.changeset/1),
      character_skills: character.character_skills |> CharacterSkill.add_missing_defaults
  end

  def update(conn, params = %{"id" => id, "character" => character_params}) do
    character = Character.full_character(id)

    changemap = %{
      root: character |> Character.changeset(character_params),
      talents: child_changesets(params["talents"], Talent, character.talents),
      attacks: child_changesets(params["attacks"], Attack, character.attacks),
      character_skills: character_skill_changesets(params["skills"], character.character_skills)
    }

    if Changemap.valid?(changemap) do
      changemap
        |> Changemap.apply
        |> Changemap.delete_missing

      redirect conn, to: character_path(conn, :show, id)
    else

      render_edit conn,
        character: changemap.root,
        talents: changemap.talents,
        attacks: changemap.attacks,
        character_skills: changemap.character_skills,
        errors: changemap.root.errors
    end
  end

  def delete(conn, %{"id" => id}) do
    Character.full_character(id) |> Character.delete
    redirect conn, to: character_path(conn, :index)
  end

  defp render_new(conn, assignments \\ []) do
    assignments = Keyword.merge(assignments, [
      title: "New Character",
      header: EdgeBuilder.CharacterView.render("_form_header.html"),
      nav_header: EdgeBuilder.CharacterView.render("_form_nav_header.html"),
      footer: EdgeBuilder.CharacterView.render("footer.html"),
      character: (if is_nil(assignments[:character]), do: %Character{} |> Character.changeset, else: assignments[:character]),
      talents: (if is_nil(assignments[:talents]) || Enum.empty?(assignments[:talents]), do: [%Talent{} |> Talent.changeset], else: assignments[:talents]),
      attacks: (if is_nil(assignments[:attacks]) || Enum.empty?(assignments[:attacks]), do: [%Attack{} |> Attack.changeset], else: assignments[:attacks]),
      character_skills: CharacterSkill.add_missing_defaults(assignments[:character_skills] || [])
    ])

    render conn, "new.html", assignments
  end

  defp render_edit(conn, assignments) do
    assignments = Keyword.merge(assignments, [
      title: "Editing #{Ecto.Changeset.get_field(assignments[:character], :name)}",
      header: EdgeBuilder.CharacterView.render("_form_header.html"),
      nav_header: EdgeBuilder.CharacterView.render("_form_nav_header.html"),
      footer: EdgeBuilder.CharacterView.render("footer.html"),
      character: (if is_nil(assignments[:character]), do: %Character{} |> Character.changeset, else: assignments[:character]),
      talents: (if is_nil(assignments[:talents]) || Enum.empty?(assignments[:talents]), do: [%Talent{} |> Talent.changeset], else: assignments[:talents]),
      attacks: (if is_nil(assignments[:attacks]) || Enum.empty?(assignments[:attacks]), do: [%Attack{} |> Attack.changeset], else: assignments[:attacks]),
      character_skills: CharacterSkill.add_missing_defaults(assignments[:character_skills] || [])
    ])

    render conn, "edit.html", assignments
  end

  defp child_changesets(params, child_model, instances \\ [])
  defp child_changesets(params, child_model, instances) when is_map(params) do
    params
      |> Map.values
      |> Enum.map(&(to_changeset(&1, child_model, instances)))
      |> Enum.reject(&child_model.is_default_changeset?/1)
  end
  defp child_changesets(_,_,_), do: []

  defp to_changeset(params = %{"id" => id}, model, instances) when not is_nil(id) do
    Enum.find(instances, &(to_string(&1.id) == to_string(id))) |> model.changeset(params)
  end
  defp to_changeset(params, model, _), do: model.changeset(struct(model), params)

  defp character_skill_changesets(params, instances \\ [])
  defp character_skill_changesets(params, instances) when is_map(params) do
    params
      |> Map.values
      |> Enum.map(&(Map.put(&1, "is_career", !is_nil(&1["is_career"]))))
      |> Enum.map(&(to_changeset(&1, CharacterSkill, instances)))
      |> Enum.reject(&CharacterSkill.is_default_changeset?/1)
  end
  defp character_skill_changesets(_,_), do: []
end
