defmodule EdgeBuilder.Models.Character do
  use EdgeBuilder.Model

  alias EdgeBuilder.Models.Talent
  alias EdgeBuilder.Models.Attack
  alias EdgeBuilder.Models.CharacterSkill

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
    field :critical_injuries, :string

    has_many :talents, Talent
    has_many :attacks, Attack
    has_many :character_skills, CharacterSkill
  end

  def changeset(character, params \\ %{}) do
    character
      |> cast(params, required_fields, optional_fields)
  end

  def full_character(id) do
    Repo.one!(
      from c in __MODULE__,
        where: c.id == ^id,
        preload: [:talents, :attacks, :character_skills]
    )
  end

  def delete(character) do
    Enum.each [Talent, Attack, CharacterSkill], fn(child_module) ->
      Repo.delete_all(from c in child_module, where: c.character_id == ^character.id)
    end

    Repo.delete(character)
  end

  defp required_fields, do: [:name, :species, :career]
  defp optional_fields, do: __schema__(:fields) -- [:id | required_fields]
end
