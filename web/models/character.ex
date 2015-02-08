defmodule EdgeBuilder.Models.Character do
  use Ecto.Model

  alias EdgeBuilder.Models.Talent
  alias EdgeBuilder.Models.Attack

  schema "characters" do
    field :name, :string
    field :species, :string
    field :career, :string
    field :specializations, :string
    field :portrait_url, :string
    field :soak, :integer
    field :wounds_threshold, :integer
    field :wounds_current, :integer
    field :strain_threshold, :integer
    field :strain_current, :integer
    field :defense_ranged, :integer
    field :defense_melee, :integer
    field :characteristic_brawn, :integer
    field :characteristic_agility, :integer
    field :characteristic_intellect, :integer
    field :characteristic_cunning, :integer
    field :characteristic_willpower, :integer
    field :characteristic_presence, :integer
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

    has_many :talents, Talent
    has_many :attacks, Attack
  end

  def full_character(id) do
    EdgeBuilder.Repo.one from c in EdgeBuilder.Models.Character, where: c.id == ^id, preload: [:talents, :attacks]
  end
end
