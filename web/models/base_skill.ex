defmodule EdgeBuilder.Models.BaseSkill do
  use EdgeBuilder.Web, :model

  schema "base_skills" do
    field :name, :string
    field :characteristic, :string
    field :display_order, :integer
    field :skill_group, :string
    field :is_attack_skill, :boolean, default: false
    field :system, Ecto.Types.Enumeration
  end

  def changeset(base_skill \\ %EdgeBuilder.Models.BaseSkill{}, params) do
    base_skill
    |> cast(params, [], ~w(name characteristic display_order is_attack_skill system skill_group))
    |> default_skill_group
  end

  def all do
    Repo.all(
      from bs in __MODULE__,
        order_by: :display_order
    )
  end

  def by_name(name) do
    Repo.one(
      from bs in __MODULE__,
        where: bs.name == ^name
    )
  end

  def by_name_and_characteristic(name, characteristic) do
    Repo.one(
      from bs in __MODULE__,
        where: bs.name == ^name,
        where: bs.characteristic == ^characteristic
    )
  end

  def attack_skills(system \\ :eote) do
    Repo.all(
      from bs in __MODULE__,
        where: bs.is_attack_skill == true,
        where: bs.system == ^system or is_nil(bs.system),
        order_by: :display_order
    )
  end

  defp default_skill_group(changeset) do
    case {_skill_group, name} = {Ecto.Changeset.get_change(changeset, :skill_group), Ecto.Changeset.get_change(changeset, :name)} do
      {nil, nil} -> changeset
      {nil, _} -> Ecto.Changeset.put_change(changeset, :skill_group, name)
      _ -> changeset
    end
  end
end
