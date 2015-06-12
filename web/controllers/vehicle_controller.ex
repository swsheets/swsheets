defmodule EdgeBuilder.VehicleController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.Vehicle

  plug Plug.Authentication, except: [:show]
  plug :action

  def new(conn, _params) do
    render conn, :new,
      title: "New Character",
      vehicle: %Vehicle{} |> Vehicle.changeset(current_user_id(conn))
  end

  def create(conn, _params) do
  end
end
