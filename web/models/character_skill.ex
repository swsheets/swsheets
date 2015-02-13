defmodule EdgeBuilder.Models.CharacterSkill do
  use Ecto.Model

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.BaseSkill

  schema "character_skills" do
    field :is_career, :boolean, default: false
    field :rank, :integer, default: 0

    belongs_to :character, Character
    belongs_to :base_skill, BaseSkill
  end
end
