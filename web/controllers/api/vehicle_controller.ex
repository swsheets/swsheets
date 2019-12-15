defmodule EdgeBuilder.API.VehicleController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.Vehicle
  alias EdgeBuilder.Repositories.VehicleRepo

  plug Plug.Authentication

  def update(conn, %{"id" => id, "vehicle" => vehicle_params}) do
    vehicle = VehicleRepo.full_vehicle(id)

    if !is_owner?(conn, vehicle) do
      put_status(conn, 403)
    else
      changes = Vehicle.changeset(vehicle, current_user_id(conn), vehicle_params)

      case EdgeBuilder.Repo.update(changes) do
        {:ok, _} ->
          put_status(conn, 200)
          |> json(%{ok: true})
        {:error, changeset} ->
          put_status(conn, 400)
          |> json(%{errors: map_errors(changeset.errors)})
      end
    end
  end

  defp map_errors(errors) do
    Enum.reduce(errors, %{}, fn({field, {message, _}}, acc) ->
      Map.put(acc, field, message)
    end)
  end
end
