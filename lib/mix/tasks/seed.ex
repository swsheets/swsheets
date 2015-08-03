defmodule Mix.Tasks.Seed do
  use Mix.Task

  alias EdgeBuilder.Models.BaseSkill
  alias EdgeBuilder.Repo

  @shortdoc "Seed the database with default data"

  @moduledoc @shortdoc
  def run(_) do
    EdgeBuilder.Repo.start_link
    seed_skills
  end

  defp seed_skills do
    base_skills = [
      %{
        name: "Astrogation",
        characteristic: "Intellect"
      },
      %{
        name: "Athletics",
        characteristic: "Brawn"
      },
      %{
        name: "Charm",
        characteristic: "Presence"
      },
      %{
        name: "Coercion",
        characteristic: "Willpower"
      },
      %{
        name: "Computers",
        characteristic: "Intellect"
      },
      %{
        name: "Cool",
        characteristic: "Presence"
      },
      %{
        name: "Coordination",
        characteristic: "Agility"
      },
      %{
        name: "Deception",
        characteristic: "Cunning"
      },
      %{
        name: "Discipline",
        characteristic: "Willpower"
      },
      %{
        name: "Leadership",
        characteristic: "Presence"
      },
      %{
        name: "Mechanics",
        characteristic: "Intellect"
      },
      %{
        name: "Medicine",
        characteristic: "Intellect"
      },
      %{
        name: "Negotiation",
        characteristic: "Presence"
      },
      %{
        name: "Perception",
        characteristic: "Cunning"
      },
      %{
        name: "Piloting: Planetary",
        characteristic: "Agility"
      },
      %{
        name: "Piloting: Space",
        characteristic: "Agility"
      },
      %{
        name: "Resilience",
        characteristic: "Brawn"
      },
      %{
        name: "Skulduggery",
        characteristic: "Cunning"
      },
      %{
        name: "Stealth",
        characteristic: "Agility"
      },
      %{
        name: "Streetwise",
        characteristic: "Cunning"
      },
      %{
        name: "Survival",
        characteristic: "Cunning"
      },
      %{
        name: "Vigilance",
        characteristic: "Willpower"
      },
      %{
        name: "Brawl",
        characteristic: "Brawn",
        is_attack_skill: true,
      },
      %{
        name: "Gunnery",
        characteristic: "Agility",
        is_attack_skill: true,
      },
      %{
        name: "Lightsaber",
        characteristic: "Brawn",
        is_attack_skill: true,
        skill_group: "Lightsaber",
        system: :fad
      },
      %{
        name: "Lightsaber",
        characteristic: "Agility",
        is_attack_skill: true,
        skill_group: "Lightsaber",
        system: :fad
      },
      %{
        name: "Lightsaber",
        characteristic: "Intellect",
        is_attack_skill: true,
        skill_group: "Lightsaber",
        system: :fad
      },
      %{
        name: "Lightsaber",
        characteristic: "Cunning",
        is_attack_skill: true,
        skill_group: "Lightsaber",
        system: :fad
      },
      %{
        name: "Lightsaber",
        characteristic: "Willpower",
        is_attack_skill: true,
        skill_group: "Lightsaber",
        system: :fad
      },
      %{
        name: "Lightsaber",
        characteristic: "Presence",
        is_attack_skill: true,
        skill_group: "Lightsaber",
        system: :fad
      },
      %{
        name: "Melee",
        characteristic: "Brawn",
        is_attack_skill: true,
      },
      %{
        name: "Ranged: Light",
        characteristic: "Agility",
        is_attack_skill: true,
      },
      %{
        name: "Ranged: Heavy",
        characteristic: "Agility",
        is_attack_skill: true,
      },
      %{
        name: "Knowledge: Core Worlds",
        characteristic: "Intellect"
      },
      %{
        name: "Knowledge: Education",
        characteristic: "Intellect"
      },
      %{
        name: "Knowledge: Lore",
        characteristic: "Intellect"
      },
      %{
        name: "Knowledge: Outer Rim",
        characteristic: "Intellect"
      },
      %{
        name: "Knowledge: Underworld",
        characteristic: "Intellect"
      },
      %{
        name: "Knowledge: Warfare",
        characteristic: "Intellect",
        system: :aor
      },
      %{
        name: "Knowledge: Xenology",
        characteristic: "Intellect"
      },
    ]

    base_skills
    |> Enum.with_index
    |> Enum.map( fn({skill, i}) ->
      Map.put(skill, :display_order, i)
      |> insert_or_update_skill
    end)
  end

  defp insert_or_update_skill(base_skill = %{name: name, characteristic: characteristic}) do
    case BaseSkill.by_name_and_characteristic(name, characteristic) do
      nil -> BaseSkill.changeset(base_skill) |> Repo.insert!
      current_skill -> BaseSkill.changeset(current_skill, base_skill) |> Repo.update!
    end
  end
end
