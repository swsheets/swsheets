defmodule EdgeBuilder.Models.ForcePowerUpgrade do
  use EdgeBuilder.Web, :model

  alias EdgeBuilder.Models.ForcePower

  schema "force_power_upgrades" do
    field :name, :string
    field :description, :string
    field :display_order, :integer, default: 0

    belongs_to :force_power, ForcePower
  end

  def changeset(force_power_upgrade, params \\ %{}) do
    force_power_upgrade
    |> cast(params, ~w(force_power_id name description display_order))
  end

  def is_default_changeset?(changeset) do
    default = struct(__MODULE__)

    Enum.all?([:name, :description], fn field ->
      value = Ecto.Changeset.get_field(changeset, field)
      is_nil(value) || value == Map.fetch!(default, field)
    end)
  end
end
