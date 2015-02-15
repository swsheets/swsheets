defmodule EdgeBuilder.Models.BaseSkill do
  use Ecto.Model

  schema "base_skills" do
    field :name, :string
    field :characteristic, :string
    field :skill_position, :integer
    field :is_attack_skill, :boolean, default: false
  end
end
