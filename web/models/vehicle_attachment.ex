defmodule EdgeBuilder.Models.VehicleAttachment do
  use EdgeBuilder.Web, :model

  alias EdgeBuilder.Models.Vehicle

  schema "vehicle_attachments" do
    field :weapon_name, :string
    field :firing_arc, :string
    field :damage, :string
    field :range, :string
    field :critical, :string
    field :specials, :string
    field :display_order, :integer, default: 0
    belongs_to :vehicle, Vehicle
  end

  def changeset(vehicle_attachments, params \\ %{}) do
    vehicle_attachments
    |> cast(params, [], ~w(vehicle_id weapon_name firing_arc damage range critical specials))
  end

  def is_default_changeset?(changeset) do
    default = struct(__MODULE__)

    Enum.all?([:weapon_name, :firing_arc, :damage, :range, :critical, :specials], fn field ->
      Ecto.Changeset.get_field(changeset, field) == Map.fetch!(default, field)
    end)
  end
end
