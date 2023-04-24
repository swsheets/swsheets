defmodule EdgeBuilder.Controllers.API.VehicleControllerTest do
  use EdgeBuilder.ConnCase

  alias Factories.VehicleFactory
  alias Factories.UserFactory
  alias EdgeBuilder.Repo
  alias EdgeBuilder.Models.Vehicle

  describe "update" do
    it "updates basic characteristics of a vehicle" do
      vehicle =
        VehicleFactory.create_vehicle(
          user_id: UserFactory.default_user().id,
          strain_current: 0,
          hull_current: 1,
          defense_fore_current: 2,
          defense_aft_current: 3,
          defense_port_current: 4,
          defense_starboard_current: 5,
          current_speed: 5
        )

      conn =
        build_conn()
        |> authenticate_as(UserFactory.default_user())
        |> json_put("/api/vehicles/#{vehicle.permalink}", %{
          vehicle: %{
            strain_current: 5,
            hull_current: -1,
            defense_fore_current: 3,
            defense_aft_current: 6,
            defense_port_current: 0,
            defense_starboard_current: 7,
            current_speed: 2
          }
        })

      assert conn.status == 200
      vehicle = Repo.get(Vehicle, vehicle.id)

      assert vehicle.strain_current == 5
      assert vehicle.hull_current == -1
      assert vehicle.defense_fore_current == 3
      assert vehicle.defense_aft_current == 6
      assert vehicle.defense_port_current == 0
      assert vehicle.defense_starboard_current == 7
      assert vehicle.current_speed == 2
    end

    it "returns errors properly" do
      vehicle =
        VehicleFactory.create_vehicle(user_id: UserFactory.default_user().id, strain_current: 0)

      conn =
        build_conn()
        |> authenticate_as(UserFactory.default_user())
        |> json_put("/api/vehicles/#{vehicle.permalink}", %{
          vehicle: %{
            name: "",
            faction: String.duplicate("a", 256),
            type: String.duplicate("a", 256),
            portrait_url: "https://" <> String.duplicate("a", 2049)
          }
        })

      assert conn.resp_body
             |> Poison.decode!() == %{
               "errors" => %{
                 "name" => "can't be blank",
                 "faction" => "should be at most 255 character(s)",
                 "type" => "should be at most 255 character(s)",
                 "portrait_url" => "should be at most 2048 character(s)"
               }
             }
    end

    it "requires authentication" do
      conn = build_conn() |> json_put("/api/vehicles/doesnt-matter")

      assert requires_authentication?(conn)
    end

    it "requires the current user to match the owning user" do
      owner = UserFactory.default_user()
      other = UserFactory.create_user!(username: "other")
      vehicle = VehicleFactory.create_vehicle(user_id: owner.id)

      conn =
        build_conn()
        |> authenticate_as(other)
        |> json_put("/api/vehicles/#{vehicle.permalink}", %{vehicle: %{strain_current: 5}})

      assert conn.status == 403
    end
  end
end
