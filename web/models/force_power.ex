defmodule EdgeBuilder.Models.ForcePower do
  use EdgeBuilder.Web, :model

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.ForcePowerUpgrade

  schema "force_powers" do
    field :name, :string
    field :description, :string
    field :display_order, :integer, default: 0

    belongs_to :character, Character
    has_many :force_power_upgrades, ForcePowerUpgrade
  end

  def changeset(force_power, params \\ %{}) do
    force_power
    |> cast(params, ~w(character_id name description display_order))
  end

  def is_default_changeset?(%{root: force_power_changeset, force_power_upgrades: upgrade_changesets}) do
    is_default_changeset?(force_power_changeset) && !Enum.any?(upgrade_changesets)
  end
  def is_default_changeset?(changeset) do
    default = struct(__MODULE__)

    Enum.all?([:name, :description], fn field ->
      value = Ecto.Changeset.get_field(changeset, field)
      is_nil(value) || value == Map.fetch!(default, field)
    end)
  end

  def for_character(character_id) do
    Repo.all(
      from t in __MODULE__,
        where: t.character_id == ^character_id,
        preload: [:force_power_upgrades]
    )
  end
end
