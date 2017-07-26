defmodule EdgeBuilder.Models.Vehicle do
  use EdgeBuilder.Web, :model

  alias EdgeBuilder.Models.VehicleAttack
  alias EdgeBuilder.Models.VehicleAttachment

  @derive {Phoenix.Param, key: :permalink}
  schema "vehicles" do
    field :url_slug, :string, read_after_writes: true
    field :permalink, :string, virtual: true
    field :name, :string
    field :make, :string
    field :hard_points, :integer, default: 0
    field :encumbrance, :string
    field :silhouette, :integer, default: 1
    field :speed, :integer, default: 1
    field :current_speed, :integer, default: 0
    field :handling, :integer, default: 0
    field :armor, :integer, default: 0
    field :hull_threshold, :integer, default: 0
    field :hull_current, :integer, default: 0
    field :strain_threshold, :integer, default: 0
    field :strain_current, :integer, default: 0
    field :defense_fore, :integer, default: 0
    field :defense_fore_current, :integer, default: 0
    field :defense_aft, :integer, default: 0
    field :defense_aft_current, :integer, default: 0
    field :defense_port, :integer, default: 0
    field :defense_port_current, :integer, default: 0
    field :defense_starboard, :integer, default: 0
    field :defense_starboard_current, :integer, default: 0
    field :sensor_range, :string, default: "Short"
    field :cargo, :string
    field :notes, :string
    field :hyperdrive, :string, default: "Primary: Class 2, Backup: None"
    field :crew, :string
    field :passengers, :string
    field :consumables, :string
    field :price, :string
    field :rarity, :string
    field :special_features, :string
    field :faction, :string
    field :portrait_url, :string
    field :type, :string

    timestamps()
    belongs_to :user, User

    has_many :vehicle_attacks, VehicleAttack
    has_many :vehicle_attachments, VehicleAttachment
  end

  defp required_fields, do: [:name]
  defp allowed_fields, do: __schema__(:fields) -- [:id, :url_slug]

  def changeset(vehicle, user_id, params \\ %{}) do
    vehicle
    |> cast(Map.put(params, "user_id", user_id), allowed_fields())
    |> validate_required(required_fields())
    |> Ecto.Changeset.delete_change(:url_slug)
  end

  def full_vehicle(permalink) do
    url_slug = String.replace(permalink, ~r/-.*/, "")

    Repo.one!(
      from v in __MODULE__,
        where: v.url_slug == ^url_slug,
        preload: [:vehicle_attacks, :vehicle_attachments]
    ) |> set_permalink()
  end

  def delete(vehicle) do
    Enum.each [VehicleAttack, VehicleAttachment], fn(child_module) ->
      Repo.delete_all(from c in child_module, where: c.vehicle_id == ^vehicle.id)
    end

    Repo.delete!(vehicle)
  end

  def set_permalink(vehicle) do
    Map.put(vehicle, :permalink, "#{vehicle.url_slug}-#{urlify(vehicle.name)}")
  end

  defp urlify(name) do
    String.replace(name, ~r/\W/, "-")
    |> String.slice(0, 15)
    |> String.downcase
  end
end
