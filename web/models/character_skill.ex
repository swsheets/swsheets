defmodule EdgeBuilder.Models.CharacterSkill do
  use EdgeBuilder.Web, :model

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.BaseSkill

  schema "character_skills" do
    field :is_career, :boolean, default: false
    field :characteristic, :string
    field :rank, :integer, default: 0

    belongs_to :character, Character
    belongs_to :base_skill, BaseSkill
  end

  def changeset(character_skill, params \\ %{}) do
    character_skill
    |> cast(params, ~w(base_skill_id character_id is_career rank characteristic))
    |> validate_required(:base_skill_id)
  end

  def for_character(id) do
    Repo.all(
      from cs in __MODULE__,
        where: cs.character_id == ^id
    )
  end

  def is_default_changeset?(changeset) do
    has_default_values?(changeset) && has_default_characteristic?(changeset)
  end

  defp has_default_values?(changeset) do
    default = struct(__MODULE__)

    Enum.all?([:rank, :is_career], fn field ->
      value = Ecto.Changeset.get_field(changeset, field)
      is_nil(value) || value == Map.fetch!(default, field)
    end)
  end

  defp has_default_characteristic?(changeset) do
    base_skill_id = Ecto.Changeset.get_field(changeset, :base_skill_id)
    characteristic = Ecto.Changeset.get_field(changeset, :characteristic)

    if is_nil(base_skill_id) || is_nil(characteristic) do
      true
    else
      base_skill = Repo.get(BaseSkill, base_skill_id)

      BaseSkill.default_characteristic(base_skill) == characteristic
    end
  end

  def add_missing_defaults(character_skills) do
    BaseSkill.all
    |> Enum.map(&(character_skill_or_default(&1, character_skills)))
  end

  defp character_skill_or_default(base_skill, character_skills_or_changesets) do
    skill_template = %{
      name: base_skill.name,
      characteristics: base_skill.characteristics,
      base_skill_id: base_skill.id,
      is_attack_skill: base_skill.is_attack_skill,
      display_order: base_skill.display_order,
      system: base_skill.system
    }

    character_skill_or_changeset = Enum.find(character_skills_or_changesets, %EdgeBuilder.Models.CharacterSkill{}, &(Extensions.Changeset.get_field(&1, :base_skill_id) == base_skill.id))

    skill_map = Map.merge(skill_template, Extensions.Changeset.take(character_skill_or_changeset, [:rank, :is_career, :id, :characteristic]))

    if is_nil(skill_map.characteristic) do
      Map.put(skill_map, :characteristic, BaseSkill.default_characteristic(base_skill))
    else
      skill_map
    end
  end
end
