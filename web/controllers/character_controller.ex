defmodule EdgeBuilder.CharacterController do
  use EdgeBuilder.Web, :controller

  import EdgeBuilder.Router.Helpers
  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.Talent
  alias EdgeBuilder.Models.Attack
  alias EdgeBuilder.Models.CharacterSkill
  alias EdgeBuilder.Models.ForcePower
  alias EdgeBuilder.Models.ForcePowerUpgrade
  alias EdgeBuilder.Repo
  alias EdgeBuilder.Repositories.CharacterRepo
  alias EdgeBuilder.Changemap

  plug Plug.Authentication, except: [:show, :index]

  @empty_force_power %ForcePower{force_power_upgrades: [%ForcePowerUpgrade{}]}

  def new(conn, _params) do
    render_new conn
  end

  def create(conn, params = %{"character" => character_params}) do
    changemap = %{
      root: Character.changeset(%Character{}, current_user_id(conn), character_params),
      talents: child_changesets(params["talents"], Talent),
      attacks: child_changesets(params["attacks"], Attack),
      character_skills: character_skill_changesets(params["skills"]),
      force_powers: force_power_changesets(params["force_powers"])
    }

    if Changemap.valid?(changemap) do
      changes = Changemap.apply_changes(changemap)

      redirect conn, to: character_path(conn, :show, changes.root)
    else
      render_new conn,
        character: changemap.root,
        talents: changemap.talents,
        attacks: changemap.attacks,
        character_skills: changemap.character_skills,
        force_powers: changemap.force_powers,
        errors: changemap.root.errors
    end
  end

  def index(conn, params) do
    page = EdgeBuilder.Repositories.CharacterRepo.all(params["page"])

    render conn, :index,
      title: "Characters",
      characters: page.entries,
      page_number: page.page_number,
      total_pages: page.total_pages
  end

  def show(conn, %{"id" => id}) do
    character = CharacterRepo.full_character(id)
    user = Repo.get!(User, character.user_id)

    render conn, :show,
      title: character.name,
      description: description_for_character(character, user),
      og_image_url: character.portrait_url,
      character: character |> Character.changeset(current_user_id(conn)),
      talents: character.talents |> Enum.map(&Talent.changeset/1),
      attacks: character.attacks |> Enum.map(&Attack.changeset/1),
      character_skills: character.character_skills |> CharacterSkill.add_missing_defaults,
      force_powers: character.force_powers |> Enum.map(&to_force_power_changeset/1),
      viewed_by_owner: is_owner?(conn, character),
      user: user
  end

  def edit(conn, %{"id" => id}) do
    character = CharacterRepo.full_character(id)

    if !is_owner?(conn, character) do
      redirect conn, to: "/"
    else
      render_edit conn,
        character: character |> Character.changeset(current_user_id(conn)),
        talents: (if Enum.empty?(character.talents), do: [%Talent{}], else: character.talents) |> Enum.map(&Talent.changeset/1),
        attacks: (if Enum.empty?(character.attacks), do: [%Attack{}], else: character.attacks) |> Enum.map(&Attack.changeset/1),
        character_skills: character.character_skills |> CharacterSkill.add_missing_defaults,
        force_powers: (if Enum.empty?(character.force_powers), do: [@empty_force_power], else: character.force_powers) |> Enum.map(&to_force_power_changeset/1)
    end
  end

  def update(conn, params = %{"id" => id, "character" => character_params}) do
    character = CharacterRepo.full_character(id)

    if !is_owner?(conn, character) do
      redirect conn, to: "/"
    else 
      changemap = %{
        root: character |> Character.changeset(current_user_id(conn), character_params),
        talents: child_changesets(params["talents"], Talent, character.talents),
        attacks: child_changesets(params["attacks"], Attack, character.attacks),
        character_skills: character_skill_changesets(params["skills"], character.character_skills),
        force_powers: force_power_changesets(params["force_powers"], character.force_powers)
      }

      if Changemap.valid?(changemap) do
        changemap
        |> Changemap.apply_changes
        |> Changemap.delete_missing

        redirect conn, to: character_path(conn, :show, changemap.root.data)
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
    character = CharacterRepo.full_character(id)

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
      character: (if is_nil(assignments[:character]), do: %Character{} |> Character.changeset(current_user_id(conn)), else: assignments[:character]),
      talents: (if is_nil(assignments[:talents]) || Enum.empty?(assignments[:talents]), do: [%Talent{} |> Talent.changeset], else: assignments[:talents]),
      attacks: (if is_nil(assignments[:attacks]) || Enum.empty?(assignments[:attacks]), do: [%Attack{} |> Attack.changeset], else: assignments[:attacks]),
      force_powers: (if is_nil(assignments[:force_powers]) || Enum.empty?(assignments[:force_powers]), do: [@empty_force_power |> to_force_power_changeset], else: assignments[:force_powers]),
      character_skills: CharacterSkill.add_missing_defaults(assignments[:character_skills] || [])
    ])

    render conn, :new, assignments
  end

  defp render_edit(conn, assignments) do
    assignments = Keyword.merge(assignments, [
      title: "Editing #{Ecto.Changeset.get_field(assignments[:character], :name)}",
      character: assignments[:character],
      talents: (if is_nil(assignments[:talents]) || Enum.empty?(assignments[:talents]), do: [%Talent{} |> Talent.changeset], else: assignments[:talents]),
      attacks: (if is_nil(assignments[:attacks]) || Enum.empty?(assignments[:attacks]), do: [%Attack{} |> Attack.changeset], else: assignments[:attacks]),
      character_skills: CharacterSkill.add_missing_defaults(assignments[:character_skills] || []),
      force_powers: (if is_nil(assignments[:force_powers]) || Enum.empty?(assignments[:force_powers]), do: [@empty_force_power |> to_force_power_changeset], else: assignments[:force_powers]),
      character_skills: CharacterSkill.add_missing_defaults(assignments[:character_skills] || [])
    ])

    render conn, :edit, assignments
  end

  defp child_changesets(params, child_model, instances \\ [])
  defp child_changesets(params, child_model, instances) when is_map(params) do
    params
    |> Map.values
    |> Enum.map(&(to_changeset(&1, child_model, instances)))
    |> Enum.reject(&child_model.is_default_changeset?/1)
  end
  defp child_changesets(_,_,_), do: []

  defp force_power_changesets(params, instances \\ [])
  defp force_power_changesets(params, instances) when is_map(params) do
    params
    |> Map.values
    |> Enum.map( fn parameters ->
      to_changeset(parameters, ForcePower, instances)
      |> with_upgrades(parameters["force_power_upgrades"])
    end)
    |> Enum.reject(&ForcePower.is_default_changeset?/1)
  end
  defp force_power_changesets(_,_), do: []

  defp with_upgrades(force_power, upgrade_params) do
    instances = case Ecto.Changeset.get_field(force_power, :force_power_upgrades) do
      %Ecto.Association.NotLoaded{} -> []
      upgrades -> upgrades
    end

    %{root: force_power,
      force_power_upgrades: child_changesets(upgrade_params, ForcePowerUpgrade, instances)}
  end

  defp to_changeset(params = %{"id" => id}, model, instances) when not is_nil(id) do
    Enum.find(instances, &(to_string(&1.id) == to_string(id))) |> model.changeset(params)
  end
  defp to_changeset(params, model, _) do
    model.changeset(struct(model), params)
  end

  defp character_skill_changesets(params, instances \\ [])
  defp character_skill_changesets(params, instances) when is_map(params) do
    params
    |> Map.values
    |> Enum.map(&(Map.put(&1, "is_career", !is_nil(&1["is_career"]))))
    |> Enum.map(&(to_changeset(&1, CharacterSkill, instances)))
    |> Enum.reject(&CharacterSkill.is_default_changeset?/1)
  end
  defp character_skill_changesets(_,_), do: []

  defp to_force_power_changeset(force_power) do
    force_power = if Enum.empty?(force_power.force_power_upgrades) do
      Map.put(force_power, :force_power_upgrades, [%ForcePowerUpgrade{}])
    else
      force_power
    end

    force_power
    |> Map.put(:force_power_upgrades, Enum.map(force_power.force_power_upgrades, &ForcePowerUpgrade.changeset/1))
    |> ForcePower.changeset
  end

  defp description_for_character(character, user) do
    %{username: username} = user
    %{name: name, species: species, specializations: specializations, career: career, background: bg} = character
    "#{name} is #{a_or_an(species)} #{species} #{career} created by #{username} specializing in #{specializations}. #{bg}"
    |> String.trim()
    |> String.replace(~r/[\s\n\r]+/, " ")
  end

  defp a_or_an(word) do
    if Regex.match? ~r/^[aeiou]/, String.downcase(word) do
      "an"
    else
      "a"
    end
  end
end
