defmodule EdgeBuilder.Models.Character do
  use Ecto.Model

  alias EdgeBuilder.Models.Talent
  alias EdgeBuilder.Models.Attack
  alias EdgeBuilder.Models.CharacterSkill
  alias EdgeBuilder.Models.BaseSkill
  alias EdgeBuilder.Repo

  schema "characters" do
    field :name, :string
    field :species, :string
    field :career, :string
    field :specializations, :string
    field :portrait_url, :string
    field :soak, :integer, default: 0
    field :wounds_threshold, :integer, default: 0
    field :wounds_current, :integer, default: 0
    field :strain_threshold, :integer, default: 0
    field :strain_current, :integer, default: 0
    field :defense_ranged, :integer, default: 0
    field :defense_melee, :integer, default: 0
    field :characteristic_brawn, :integer, default: 1
    field :characteristic_agility, :integer, default: 1
    field :characteristic_intellect, :integer, default: 1
    field :characteristic_cunning, :integer, default: 1
    field :characteristic_willpower, :integer, default: 1
    field :characteristic_presence, :integer, default: 1
    field :gear, :string
    field :credits, :integer
    field :encumbrance, :string
    field :xp_available, :integer
    field :xp_total, :integer
    field :background, :string
    field :motivation, :string
    field :obligation, :string
    field :obligation_amount, :string
    field :description, :string
    field :other_notes, :string
    field :combined_character_skills, {:array, :any}, virtual: true

    has_many :talents, Talent
    has_many :attacks, Attack
    has_many :character_skills, CharacterSkill
  end

  def full_character(id) do
    character = Repo.one from c in EdgeBuilder.Models.Character, where: c.id == ^id, preload: [:talents, :attacks, [character_skills: :base_skill]]

    character |> populate_combined_character_skills
  end

  defp populate_combined_character_skills(character) do
    %{character | combined_character_skills:
      Repo.all(BaseSkill) |> Enum.map(&(character_skill_or_default(&1,character.character_skills)))
    }
  end

  defp character_skill_or_default(base_skill, character_skills) do
    skill_template = %{
      name: base_skill.name,
      characteristic: base_skill.characteristic,
      base_skill_id: base_skill.id,
      is_attack_skill: base_skill.is_attack_skill
    }

    character_skill = Enum.find(character_skills, %CharacterSkill{}, &(&1.base_skill == base_skill))

    character_skill
      |> Map.take([:rank, :is_career, :id])
      |> Map.merge(skill_template)
  end
end
