defmodule EdgeBuilder.Models.BaseSkill do
  use Ecto.Model

  alias EdgeBuilder.Repo
  import Ecto.Query, only: [from: 2]

  schema "base_skills" do
    field :name, :string
    field :characteristic, :string
    field :skill_position, :integer
    field :is_attack_skill, :boolean, default: false
  end

  def all do
    Repo.all(__MODULE__)
  end
end
