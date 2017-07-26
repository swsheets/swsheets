defmodule EdgeBuilder.VehicleController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Changemap
  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Models.Vehicle
  alias EdgeBuilder.Models.VehicleAttack
  alias EdgeBuilder.Models.VehicleAttachment
  import Ecto.Changeset, only: [get_field: 2]

  plug Plug.Authentication, except: [:show, :index]

  def new(conn, _params) do
    render_vehicle conn, :new,
      vehicle: %Vehicle{} |> Vehicle.changeset(current_user_id(conn)),
      vehicle_attacks: [],
      vehicle_attachments: []
  end

  def create(conn, params = %{"vehicle" => vehicle_params}) do
    changemap = %{
      root: Vehicle.changeset(%Vehicle{}, current_user_id(conn), vehicle_params),
      vehicle_attacks: child_changesets(params["attacks"], VehicleAttack),
      vehicle_attachments: child_changesets(params["attachments"], VehicleAttachment)
    }

    if Changemap.valid?(changemap)  do
      changemap = Changemap.apply_changes(changemap)

      redirect conn, to: vehicle_path(conn, :show, changemap.root)
    else
      render_vehicle conn, :new,
        vehicle: changemap.root,
        vehicle_attacks: changemap.vehicle_attacks,
        vehicle_attachments: changemap.vehicle_attachments,
        errors: changemap.root.errors
    end
  end

  def index(conn, params) do
    page = EdgeBuilder.RepoService.all_paginated(Vehicle, params["page"])

    render conn, :index,
      title: "Vehicles",
      vehicles: page.entries,
      page_number: page.page_number,
      total_pages: page.total_pages
  end

  def show(conn, %{"id" => id}) do
    vehicle = Vehicle.full_vehicle(id)
    user = Repo.get!(User, vehicle.user_id)

    render conn, :show,
      title: vehicle.name,
      vehicle: vehicle |> Vehicle.changeset(current_user_id(conn)),
      vehicle_attacks: Enum.map(vehicle.vehicle_attacks, &VehicleAttack.changeset/1),
      vehicle_attachments: Enum.map(vehicle.vehicle_attachments, &VehicleAttachment.changeset/1),
      viewed_by_owner: is_owner?(conn, vehicle),
      user: user
  end

  def edit(conn, %{"id" => id}) do
    vehicle = Vehicle.full_vehicle(id)

    if !is_owner?(conn, vehicle) do
      redirect conn, to: "/"
    else
      render_vehicle conn, :edit,
        vehicle: vehicle |> Vehicle.changeset(current_user_id(conn)),
        vehicle_attacks: Enum.map(vehicle.vehicle_attacks, &VehicleAttack.changeset/1),
        vehicle_attachments: Enum.map(vehicle.vehicle_attachments, &VehicleAttachment.changeset/1)
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
        Changemap.apply_changes(changemap)
        |> Changemap.delete_missing

        redirect conn, to: vehicle_path(conn, :show, changemap.root.data)
      else
        render_vehicle conn, :edit,
          vehicle: changemap.root,
          vehicle_attacks: changemap.vehicle_attacks,
          vehicle_attachments: changemap.vehicle_attachments,
          errors: changemap.root.errors
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    vehicle = Vehicle.full_vehicle(id)

    if !is_owner?(conn, vehicle) do
      redirect conn, to: "/"
    else
      Vehicle.delete(vehicle)
      redirect conn, to: vehicle_path(conn, :index)
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

  defp render_vehicle(conn, :new, assignments) do
    render_vehicle_base(conn, :new, Keyword.merge(assignments, title: "New Vehicle"))
  end
  defp render_vehicle(conn, :edit, assignments) do
    render_vehicle_base(conn, :edit, Keyword.merge(assignments, title: "Editing #{get_field(assignments[:vehicle], :name)}"))
  end
  defp render_vehicle_base(conn, template, assignments) do
    render conn, template,
      Keyword.merge(assignments,
        title: assignments[:title],
        vehicle: assignments[:vehicle],
        vehicle_attacks: (if Enum.empty?(assignments[:vehicle_attacks]), do: [%VehicleAttack{} |> VehicleAttack.changeset], else: assignments[:vehicle_attacks]),
        vehicle_attachments: (if Enum.empty?(assignments[:vehicle_attachments]), do: [%VehicleAttachment{} |> VehicleAttachment.changeset], else: assignments[:vehicle_attachments])
      )
  end
end
