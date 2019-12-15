defmodule EdgeBuilder.Controllers.API.VehicleControllerTest do
  use EdgeBuilder.ConnCase

  alias Factories.VehicleFactory
  alias Factories.UserFactory
  alias EdgeBuilder.Repo
  alias EdgeBuilder.Models.Vehicle

  describe "update" do
    it "updates basic characteristics of a vehicle" do
      vehicle = VehicleFactory.create_vehicle(user_id: UserFactory.default_user.id, strain_current: 0)

      conn = build_conn() |> authenticate_as(UserFactory.default_user) |> json_put("/api/vehicles/#{vehicle.permalink}", %{vehicle: %{strain_current: 5}})

      assert conn.status == 200
      vehicle = Repo.get(Vehicle, vehicle.id)

      assert vehicle.strain_current == 5
    end

    it "returns errors properly" do
      vehicle = VehicleFactory.create_vehicle(user_id: UserFactory.default_user.id, strain_current: 0)

      conn = build_conn() |> authenticate_as(UserFactory.default_user) |> json_put("/api/vehicles/#{vehicle.permalink}", %{vehicle: %{name: ""}})

      assert conn.resp_body |> Poison.decode! == %{"errors" => %{"name" => "can't be blank"}}
    end

    it "requires authentication" do
      conn = build_conn() |> json_put("/api/vehicles/doesnt-matter")

      assert requires_authentication?(conn)
    end

    it "requires the current user to match the owning user" do
      owner = UserFactory.default_user
      other = UserFactory.create_user!(username: "other")
      vehicle = VehicleFactory.create_vehicle(user_id: owner.id)

      conn = build_conn() |> authenticate_as(other) |> json_put("/api/vehicles/#{vehicle.permalink}", %{vehicle: %{strain_current: 5}})

      assert conn.status == 403
    end
  end
end
