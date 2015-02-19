defmodule EdgeBuilder.Models.CharacterSkill do
  use Ecto.Model

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.BaseSkill
  alias EdgeBuilder.Repo
  import Ecto.Query, only: [from: 2]

  schema "character_skills" do
    field :is_career, :boolean, default: false
    field :rank, :integer, default: 0

    belongs_to :character, Character
    belongs_to :base_skill, BaseSkill
  end

  def changeset(character_skill, params \\ %{}) do
    params
      |> cast(character_skill, ~w(base_skill_id), ~w(character_id is_career rank))
  end

  def for_character(id) do
    character_skills = Repo.all(
      from cs in __MODULE__,
        where: cs.character_id == ^id
    )
  end

  def is_default_changeset?(changeset) do
    default = struct(__MODULE__)

    is_nil(changeset.model.id)
      && Enum.all?([:rank, :is_career], fn field ->
        Ecto.Changeset.get_field(changeset, field) == Map.fetch!(default, field)
      end)
  end

  def add_missing_defaults(character_skills) do
    BaseSkill.all
      |> Enum.map(&(character_skill_or_default(&1, character_skills)))
  end

  defp character_skill_or_default(base_skill, character_skills) do
    skill_template = %{
      name: base_skill.name,
      characteristic: base_skill.characteristic,
      base_skill_id: base_skill.id,
      is_attack_skill: base_skill.is_attack_skill
    }

    character_skill = Enum.find(character_skills, %EdgeBuilder.Models.CharacterSkill{}, &(&1.base_skill_id == base_skill.id))

    character_skill
      |> Map.take([:rank, :is_career, :id])
      |> Map.merge(skill_template)
  end
end
