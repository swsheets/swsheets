defmodule EdgeBuilder.CharacterController do
  use EdgeBuilder.Web, :controller

  import EdgeBuilder.Router.Helpers
  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.Talent
  alias EdgeBuilder.Models.Attack
  alias EdgeBuilder.Models.CharacterSkill
  alias EdgeBuilder.Repo
  alias EdgeBuilder.Changemap
  import Ecto.Query, only: [from: 2]

  plug Plug.Authentication, except: [:show]
  plug :action

  def new(conn, _params) do
    render_new conn
  end

  def create(conn, params = %{"character" => character_params}) do
    changemap = %{
      root: Character.changeset(%Character{}, current_user_id(conn), character_params),
      talents: child_changesets(params["talents"], Talent),
      attacks: child_changesets(params["attacks"], Attack),
      character_skills: character_skill_changesets(params["skills"])
    }

    if Changemap.valid?(changemap) do
      changes = Changemap.apply(changemap)

      redirect conn, to: character_path(conn, :show, changes.root)
    else
      render_new conn,
        character: changemap.root,
        talents: changemap.talents,
        attacks: changemap.attacks,
        character_skills: changemap.character_skills,
        errors: changemap.root.errors
    end
  end

  def index(conn, params) do
    page = Repo.paginate((from c in Character, where: c.user_id == ^current_user_id(conn), order_by: [desc: c.updated_at]), page: params["page"])

    render conn, "index.html",
      title: "My Characters",
      header: EdgeBuilder.CharacterView.render("_index_header.html"),
      characters: page.entries,
      page_number: page.page_number,
      total_pages: page.total_pages
  end

  def show(conn, %{"id" => id}) do
    character = Character.full_character(id)

    render conn, "show.html",
      header: EdgeBuilder.CharacterView.render("_show_header.html"),
      footer: EdgeBuilder.CharacterView.render("footer.html"),
      title: character.name,
      character: character |> Character.changeset(current_user_id(conn)),
      talents: character.talents |> Enum.map(&Talent.changeset/1),
      attacks: character.attacks |> Enum.map(&Attack.changeset/1),
      character_skills: character.character_skills |> CharacterSkill.add_missing_defaults,
      viewed_by_owner: is_owner?(conn, character)
  end

  def edit(conn, %{"id" => id}) do
    character = Character.full_character(id)

    if !is_owner?(conn, character) do
      redirect conn, to: "/"
    else
      render_edit conn,
        character: character |> Character.changeset(current_user_id(conn)),
        talents: (if Enum.empty?(character.talents), do: [%Talent{}], else: character.talents) |> Enum.map(&Talent.changeset/1),
        attacks: (if Enum.empty?(character.attacks), do: [%Attack{}], else: character.attacks) |> Enum.map(&Attack.changeset/1),
        character_skills: character.character_skills |> CharacterSkill.add_missing_defaults
    end
  end

  def update(conn, params = %{"id" => id, "character" => character_params}) do
    character = Character.full_character(id)

    if !is_owner?(conn, character) do
      redirect conn, to: "/"
    else 
      changemap = %{
        root: character |> Character.changeset(current_user_id(conn), character_params),
        talents: child_changesets(params["talents"], Talent, character.talents),
        attacks: child_changesets(params["attacks"], Attack, character.attacks),
        character_skills: character_skill_changesets(params["skills"], character.character_skills)
      }

      if Changemap.valid?(changemap) do
        changemap
          |> Changemap.apply
          |> Changemap.delete_missing

        redirect conn, to: character_path(conn, :show, changemap.root.model)
      else
        render_edit conn,
          character: changemap.root,
          talents: changemap.talents,
          attacks: changemap.attacks,
          character_skills: changemap.character_skills,
          errors: changemap.root.errors
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    character = Character.full_character(id)

    if !is_owner?(conn, character) do
      redirect conn, to: "/"
    else
      Character.delete(character)
      redirect conn, to: character_path(conn, :index)
    end
  end

  defp render_new(conn, assignments \\ []) do
    assignments = Keyword.merge(assignments, [
      title: "New Character",
      header: EdgeBuilder.CharacterView.render("_form_header.html"),
      footer: EdgeBuilder.CharacterView.render("footer.html"),
      character: (if is_nil(assignments[:character]), do: %Character{} |> Character.changeset(current_user_id(conn)), else: assignments[:character]),
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
      footer: EdgeBuilder.CharacterView.render("footer.html"),
      character: assignments[:character],
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

  def current_user_id(conn) do
    get_session(conn, :current_user_id)
  end

  defp is_owner?(conn, character) do
    character.user_id == current_user_id(conn)
  end
end
