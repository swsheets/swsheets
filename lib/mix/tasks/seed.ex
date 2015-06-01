defmodule Mix.Tasks.Seed do
  use Mix.Task

  alias EdgeBuilder.Models.BaseSkill

  @shortdoc "Seed the database with default data"

  @moduledoc @shortdoc
  def run(_) do
    EdgeBuilder.Repo.start_link
    seed_skills
  end

  defp seed_skills do
    base_skills = [
      %BaseSkill {
        name: "Astrogation",
        characteristic: "Intellect"
      },
      %BaseSkill {
        name: "Athletics",
        characteristic: "Brawn"
      },
      %BaseSkill {
        name: "Charm",
        characteristic: "Presence"
      },
      %BaseSkill {
        name: "Coercion",
        characteristic: "Willpower"
      },
      %BaseSkill {
        name: "Computers",
        characteristic: "Intellect"
      },
      %BaseSkill {
        name: "Cool",
        characteristic: "Presence"
      },
      %BaseSkill {
        name: "Coordination",
        characteristic: "Agility"
      },
      %BaseSkill {
        name: "Deception",
        characteristic: "Cunning"
      },
      %BaseSkill {
        name: "Discipline",
        characteristic: "Willpower"
      },
      %BaseSkill {
        name: "Leadership",
        characteristic: "Presence"
      },
      %BaseSkill {
        name: "Mechanics",
        characteristic: "Intellect"
      },
      %BaseSkill {
        name: "Medicine",
        characteristic: "Intellect"
      },
      %BaseSkill {
        name: "Negotiation",
        characteristic: "Presence"
      },
      %BaseSkill {
        name: "Perception",
        characteristic: "Cunning"
      },
      %BaseSkill {
        name: "Piloting: Planetary",
        characteristic: "Agility"
      },
      %BaseSkill {
        name: "Piloting: Space",
        characteristic: "Agility"
      },
      %BaseSkill {
        name: "Resilience",
        characteristic: "Brawn"
      },
      %BaseSkill {
        name: "Skulduggery",
        characteristic: "Cunning"
      },
      %BaseSkill {
        name: "Stealth",
        characteristic: "Agility"
      },
      %BaseSkill {
        name: "Streetwise",
        characteristic: "Cunning"
      },
      %BaseSkill {
        name: "Survival",
        characteristic: "Cunning"
      },
      %BaseSkill {
        name: "Vigilance",
        characteristic: "Willpower"
      },
      %BaseSkill {
        name: "Brawl",
        characteristic: "Brawn",
        is_attack_skill: true,
      },
      %BaseSkill {
        name: "Gunnery",
        characteristic: "Agility",
        is_attack_skill: true,
      },
      %BaseSkill {
        name: "Melee",
        characteristic: "Brawn",
        is_attack_skill: true,
      },
      %BaseSkill {
        name: "Ranged: Light",
        characteristic: "Agility",
        is_attack_skill: true,
      },
      %BaseSkill {
        name: "Ranged: Heavy",
        characteristic: "Agility",
        is_attack_skill: true,
      },
      %BaseSkill {
        name: "Knowledge: Core Worlds",
        characteristic: "Intellect"
      },
      %BaseSkill {
        name: "Knowledge: Education",
        characteristic: "Intellect"
      },
      %BaseSkill {
        name: "Knowledge: Lore",
        characteristic: "Intellect"
      },
      %BaseSkill {
        name: "Knowledge: Outer Rim",
        characteristic: "Intellect"
      },
      %BaseSkill {
        name: "Knowledge: Underworld",
        characteristic: "Intellect"
      },
      %BaseSkill {
        name: "Knowledge: Xenology",
        characteristic: "Intellect"
      },
    ]

    base_skills
    |> Enum.with_index
    |> Enum.map( fn({skill, i}) -> %{skill | display_order: i} end)
    |> Enum.map(&EdgeBuilder.Repo.insert/1)
  end
end
