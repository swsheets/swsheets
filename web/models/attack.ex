defmodule EdgeBuilder.Models.Attack do
  use EdgeBuilder.Model

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

  def changeset(attack, params \\ %{}) do
    attack
      |> cast(params, [], ~w(character_id weapon_name range specials damage critical base_skill_id))
  end

  def is_default_changeset?(changeset) do
    default = struct(__MODULE__)

    Enum.all?([:weapon_name, :range, :specials, :damage, :critical, :base_skill_id], fn field ->
      Ecto.Changeset.get_field(changeset, field) == Map.fetch!(default, field)
    end)
  end

  def for_character(character_id) do
    Repo.all(
      from t in __MODULE__,
        where: t.character_id == ^character_id
    )
  end
end
