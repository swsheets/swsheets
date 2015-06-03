defmodule EdgeBuilder.Models.Character do
  use EdgeBuilder.Web, :model

  alias EdgeBuilder.Models.Talent
  alias EdgeBuilder.Models.Talent
  alias EdgeBuilder.Models.Attack
  alias EdgeBuilder.Models.CharacterSkill

  @derive {Phoenix.Param, key: :permalink}
  schema "characters" do
    field :url_slug, :string, read_after_writes: true
    field :permalink, :string, virtual: true
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
    field :weapons_and_armor, :string
    field :personal_gear, :string
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

    timestamps
    belongs_to :user, User

    has_many :talents, Talent
    has_many :attacks, Attack
    has_many :character_skills, CharacterSkill
  end

  before_insert Ecto.Changeset, :delete_change, [:url_slug]
  before_update Ecto.Changeset, :delete_change, [:url_slug]
  after_insert __MODULE__, :_set_permalink_for_changeset
  after_load __MODULE__, :_set_permalink

  defp required_fields, do: [:name, :species, :career, :user_id]
  defp optional_fields, do: __schema__(:fields) -- ([:id, :url_slug] ++ required_fields)

  def changeset(character, user_id, params \\ %{}) do
    character
    |> cast(Map.put(params, "user_id", user_id), required_fields, optional_fields)
  end

  def full_character(permalink) do
    url_slug = String.replace(permalink, ~r/-.*/, "")

    Repo.one!(
      from c in __MODULE__,
        where: c.url_slug == ^url_slug,
        preload: [:talents, :attacks, :character_skills]
    )
  end

  def delete(character) do
    Enum.each [Talent, Attack, CharacterSkill], fn(child_module) ->
      Repo.delete_all(from c in child_module, where: c.character_id == ^character.id)
    end

    Repo.delete(character)
  end

  def _set_permalink_for_changeset(changeset) do
    update_in(changeset.model, &_set_permalink/1)
  end

  def _set_permalink(character) do
    Map.put(character, :permalink, "#{character.url_slug}-#{urlify(character.name)}")
  end

  defp urlify(name) do
    String.replace(name, ~r/\W/, "-")
    |> String.slice(0, 15)
    |> String.downcase
  end
end
