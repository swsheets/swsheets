defmodule EdgeBuilder.Models.Attack do
  use Ecto.Model

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.BaseSkill

  schema "attacks" do
    field :weapon_name, :string
    field :range, :string
    field :specials, :string
    field :damage, :string
    field :critical, :string
    belongs_to :character, Character
    belongs_to :base_skill, BaseSkill
  end
end
