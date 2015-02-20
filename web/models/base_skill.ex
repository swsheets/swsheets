defmodule EdgeBuilder.Models.BaseSkill do
  use EdgeBuilder.Model

  schema "base_skills" do
    field :name, :string
    field :characteristic, :string
    field :skill_position, :integer
    field :is_attack_skill, :boolean, default: false
  end

  def all do
    Repo.all(__MODULE__)
  end

  def by_name(name) do
    Repo.one(
      from bs in __MODULE__,
        where: bs.name == ^name
    )
  end
end
