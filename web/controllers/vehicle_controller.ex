defmodule EdgeBuilder.VehicleController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Changemap
  alias EdgeBuilder.Models.Vehicle
  alias EdgeBuilder.Models.VehicleAttack
  alias EdgeBuilder.Models.VehicleAttachment
  import Ecto.Changeset, only: [get_field: 2]

  plug Plug.Authentication, except: [:show]
  plug :action

  def new(conn, _params) do
    render conn, :new,
      title: "New Vehicle",
      vehicle: %Vehicle{} |> Vehicle.changeset(current_user_id(conn)),
      vehicle_attacks: [%VehicleAttack{} |> VehicleAttack.changeset],
      vehicle_attachments: [%VehicleAttachment{} |> VehicleAttachment.changeset]
  end

  def create(conn, params = %{"vehicle" => vehicle_params}) do
    changemap = %{
      root: Vehicle.changeset(%Vehicle{}, current_user_id(conn), vehicle_params),
      vehicle_attacks: child_changesets(params["attacks"], VehicleAttack),
      vehicle_attachments: child_changesets(params["attachments"], VehicleAttachment)
    }

    if Changemap.valid?(changemap)  do
      changemap = Changemap.apply(changemap)

      redirect conn, to: vehicle_path(conn, :show, changemap.root)
    else
      render conn, :new,
        title: "New Vehicle",
        vehicle: changemap.root,
        vehicle_attacks: (if Enum.empty?(changemap.vehicle_attacks), do: [%VehicleAttack{} |> VehicleAttack.changeset], else: changemap.vehicle_attacks),
        vehicle_attachments: (if Enum.empty?(changemap.vehicle_attachments), do: [%VehicleAttachment{} |> VehicleAttachment.changeset], else: changemap.vehicle_attachments),
        errors: changemap.root.errors
    end
  end

  def edit(conn, %{"id" => id}) do
    vehicle = Vehicle.full_vehicle(id)

    if !is_owner?(conn, vehicle) do
      redirect conn, to: "/"
    else
      render conn, :edit,
        title: "Editing #{vehicle.name}",
        vehicle: vehicle |> Vehicle.changeset(current_user_id(conn)),
        vehicle_attacks: (if Enum.empty?(vehicle.vehicle_attacks), do: [%VehicleAttack{}], else: vehicle.vehicle_attacks) |> Enum.map(&VehicleAttack.changeset/1),
        vehicle_attachments: (if Enum.empty?(vehicle.vehicle_attachments), do: [%VehicleAttachment{}], else: vehicle.vehicle_attachments) |> Enum.map(&VehicleAttachment.changeset/1)
    end
  end

  def update(conn, params = %{"id" => id, "vehicle" => vehicle_params}) do
    vehicle = Vehicle.full_vehicle(id)

    changemap = %{
      root: Vehicle.changeset(vehicle, current_user_id(conn), vehicle_params),
      vehicle_attacks: child_changesets(params["attacks"], VehicleAttack, vehicle.vehicle_attacks),
      vehicle_attachments: child_changesets(params["attachments"], VehicleAttachment, vehicle.vehicle_attachments)
    }

    if !is_owner?(conn, vehicle) do
      redirect conn, to: "/"
    else
      if Changemap.valid?(changemap) do
        Changemap.apply(changemap)
        |> Changemap.delete_missing

        redirect conn, to: vehicle_path(conn, :show, changemap.root.model)
      else
        render conn, :edit,
          title: "Editing #{get_field(changemap.root, :name)}",
          vehicle: changemap.root,
          vehicle_attacks: (if Enum.empty?(changemap.vehicle_attacks), do: [%VehicleAttack{} |> VehicleAttack.changeset], else: changemap.vehicle_attacks),
          vehicle_attachments: (if Enum.empty?(changemap.vehicle_attachments), do: [%VehicleAttachment{} |> VehicleAttachment.changeset], else: changemap.vehicle_attachments),
          errors: changemap.root.errors
      end
    end
  end

  defp child_changesets(params, child_model, instances \\ [])
  defp child_changesets(params, child_model, instances) when is_map(params) do
    params
    |> Map.values
    |> Enum.map(&(to_changeset(&1, child_model, instances)))
    |> Enum.reject(&child_model.is_default_changeset?/1)
  end
  defp child_changesets(_,_,_), do: []

  defp to_changeset(params = %{"id" => id}, model, instances) when not is_nil(id) do
    Enum.find(instances, &(to_string(&1.id) == to_string(id))) |> model.changeset(params)
  end
  defp to_changeset(params, model, _), do: model.changeset(struct(model), params)
end
