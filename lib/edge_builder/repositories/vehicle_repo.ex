defmodule EdgeBuilder.Repositories.VehicleRepo do
  alias EdgeBuilder.Repo
  alias EdgeBuilder.Models.Vehicle
  import Ecto.Query, only: [from: 2]

  def all(page \\ 0) do
    Repo.paginate(
      (from v in Vehicle,
      order_by: [desc: v.inserted_at]),
      page: page)
    |> callbacks_paginated()
  end

  def all_for_user(user_id) do
    Repo.all(
      from v in Vehicle,
      where: v.user_id == ^user_id,
      order_by: [desc: v.inserted_at])
    |> Enum.map(&callbacks/1)
  end

  def recent do
    Repo.all(
      from v in Vehicle,
      order_by: [desc: v.inserted_at],
      limit: 5)
    |> Enum.map(&callbacks/1)
  end

  def full_vehicle(permalink) do
    url_slug = String.replace(permalink, ~r/-.*/, "")

    Repo.one!(
      from v in Vehicle,
        where: v.url_slug == ^url_slug,
        preload: [:vehicle_attacks, :vehicle_attachments]
    ) |> callbacks()
  end

  defp callbacks(vehicle) do
    Vehicle.set_permalink(vehicle)
  end

  defp callbacks_paginated(paged_vehicles) do
    Map.put(paged_vehicles, :entries, Enum.map(paged_vehicles.entries, &callbacks/1))
  end
end
