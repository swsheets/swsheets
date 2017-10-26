defmodule Mix.Tasks.Seed do
  use Mix.Task

  alias EdgeBuilder.Models.BaseSkill
  alias EdgeBuilder.Repo

  @shortdoc "Seed the database with default data"

  @moduledoc @shortdoc
  def run(_) do
    Mix.Task.run "app.start"
    seed_skills()
  end

  defp seed_skills do
    base_skills = [
      %{
        name: "Astrogation",
        characteristics: ["Intellect"]
      },
      %{
        name: "Athletics",
        characteristics: ["Brawn"]
      },
      %{
        name: "Charm",
        characteristics: ["Presence"]
      },
      %{
        name: "Coercion",
        characteristics: ["Willpower"]
      },
      %{
        name: "Computers",
        characteristics: ["Intellect"]
      },
      %{
        name: "Cool",
        characteristics: ["Presence"]
      },
      %{
        name: "Coordination",
        characteristics: ["Agility"]
      },
      %{
        name: "Deception",
        characteristics: ["Cunning"]
      },
      %{
        name: "Discipline",
        characteristics: ["Willpower"]
      },
      %{
        name: "Leadership",
        characteristics: ["Presence"]
      },
      %{
        name: "Mechanics",
        characteristics: ["Intellect"]
      },
      %{
        name: "Medicine",
        characteristics: ["Intellect"]
      },
      %{
        name: "Negotiation",
        characteristics: ["Presence"]
      },
      %{
        name: "Perception",
        characteristics: ["Cunning"]
      },
      %{
        name: "Piloting: Planetary",
        characteristics: ["Agility"]
      },
      %{
        name: "Piloting: Space",
        characteristics: ["Agility"]
      },
      %{
        name: "Resilience",
        characteristics: ["Brawn"]
      },
      %{
        name: "Skulduggery",
        characteristics: ["Cunning"]
      },
      %{
        name: "Stealth",
        characteristics: ["Agility"]
      },
      %{
        name: "Streetwise",
        characteristics: ["Cunning"]
      },
      %{
        name: "Survival",
        characteristics: ["Cunning"]
      },
      %{
        name: "Vigilance",
        characteristics: ["Willpower"]
      },
      %{
        name: "Brawl",
        characteristics: ["Brawn"],
        is_attack_skill: true,
      },
      %{
        name: "Gunnery",
        characteristics: ["Agility"],
        is_attack_skill: true,
      },
      %{
        name: "Lightsaber",
        characteristics: ["Brawn", "Agility", "Intellect", "Cunning", "Willpower", "Presence"],
        is_attack_skill: true,
        system: :fad
      },
      %{
        name: "Melee",
        characteristics: ["Brawn"],
        is_attack_skill: true,
      },
      %{
        name: "Ranged: Light",
        characteristics: ["Agility"],
        is_attack_skill: true,
      },
      %{
        name: "Ranged: Heavy",
        characteristics: ["Agility"],
        is_attack_skill: true,
      },
      %{
        name: "Knowledge: Core Worlds",
        characteristics: ["Intellect"]
      },
      %{
        name: "Knowledge: Education",
        characteristics: ["Intellect"]
      },
      %{
        name: "Knowledge: Lore",
        characteristics: ["Intellect"]
      },
      %{
        name: "Knowledge: Outer Rim",
        characteristics: ["Intellect"]
      },
      %{
        name: "Knowledge: Underworld",
        characteristics: ["Intellect"]
      },
      %{
        name: "Knowledge: Warfare",
        characteristics: ["Intellect"],
        system: :aor
      },
      %{
        name: "Knowledge: Xenology",
        characteristics: ["Intellect"]
      },
    ]

    base_skills
    |> Enum.with_index
    |> Enum.map( fn({skill, i}) ->
      Map.put(skill, :display_order, i)
      |> insert_or_update_skill
    end)
  end

  defp insert_or_update_skill(base_skill = %{name: name}) do
    case BaseSkill.by_name(name) do
      nil -> BaseSkill.changeset(base_skill) |> Repo.insert!
      current_skill -> BaseSkill.changeset(current_skill, base_skill) |> Repo.update!
    end
  end
end
