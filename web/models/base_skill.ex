defmodule EdgeBuilder.Models.BaseSkill do
  use Ecto.Model

  schema "base_skills" do
    field :name, :string
    field :characteristic, :string
    field :is_attack_skill, :boolean, default: false
    field :attack_skill_position, :integer
  end
end
