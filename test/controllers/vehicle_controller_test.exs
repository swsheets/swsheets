defmodule EdgeBuilder.Controllers.VehicleControllerTest do
  use EdgeBuilder.ControllerTest

  alias Helpers.FlokiExt
  alias EdgeBuilder.Models.Vehicle
  alias EdgeBuilder.Models.VehicleAttack
  alias EdgeBuilder.Models.VehicleAttachment
  alias EdgeBuilder.Repo
  alias Factories.UserFactory
  alias Factories.VehicleFactory

  describe "new" do
    it "renders the edit form for a new vehicle" do
      conn = authenticated_request(UserFactory.default_user, :get, "/v/new")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, "New Vehicle")
    end

    it "requires authentication" do
      conn = request(:get, "/v/new")

      assert requires_authentication?(conn)
    end
  end

  describe "create" do
    it "creates a vehicle" do
      authenticated_request(UserFactory.default_user, :post, "/v", %{
        "vehicle" => %{
          "armor" => "3",
          "cargo" => "1 wookie rug (missing)",
          "consumables" => "1 week",
          "crew" => "",
          "current_speed" => "0",
          "defense_aft" => "0",
          "defense_aft_current" => "0",
          "defense_fore" => "1",
          "defense_fore_current" => "1",
          "defense_port" => "0",
          "defense_port_current" => "0",
          "defense_starboard" => "0",
          "defense_starboard_current" => "0",
          "encumbrance" => "100",
          "faction" => "Thunderbirds",
          "hard_points" => "4",
          "hull_current" => "4",
          "hull_threshold" => "15",
          "hyperdrive" => "Primary: Class 2, Backup: None",
          "make" => "YT-1300",
          "name" => "Triumphant Failure",
          "notes" => "A bunch of pretty good guys, you know?",
          "passengers" => "2",
          "picture_url" => "http://example.com/foo.gif",
          "price" => "130,000",
          "rarity" => "4(R)",
          "sensor_range" => "Short",
          "silhouette" => "4",
          "special_features" => "Painted \"Spectral Guise\" on the side",
          "speed" => "5",
          "strain_current" => "6",
          "strain_threshold" => "15",
          "type" => "Ship"
        },
        "attachments" => %{
          "0" => %{"base_modifiers" => "Goes real fast like", "display_order" => "0", "hard_points_required" => "0", "id" => nil, "modifications" => "pow!", "name" => "Boost mode"}
        },
        "attacks" => %{
          "0" => %{"critical" => "3", "damage" => "7", "display_order" => "1", "firing_arc" => "All", "id" => nil, "range" => "Short", "specials" => "Pierce 2", "weapon_name" => "Dorsal Turbolaser"},
          "1" => %{"critical" => "2", "damage" => "11", "display_order" => "0", "firing_arc" => "Forward", "range" => "Medium", "specials" => "Blast 2", "weapon_name" => "Concussion Missile"}
        },
      })

      vehicle = Repo.all(Vehicle) |> Enum.at(0)

      assert vehicle.user_id == UserFactory.default_user.id
      assert vehicle.armor == 3
      assert vehicle.cargo == "1 wookie rug (missing)"
      assert vehicle.consumables == "1 week"
      assert is_nil(vehicle.crew)
      assert vehicle.current_speed == 0
      assert vehicle.defense_aft == 0
      assert vehicle.defense_aft_current == 0
      assert vehicle.defense_fore == 1
      assert vehicle.defense_fore_current == 1
      assert vehicle.defense_port == 0
      assert vehicle.defense_port_current == 0
      assert vehicle.defense_starboard == 0
      assert vehicle.defense_starboard_current == 0
      assert vehicle.encumbrance == "100"
      assert vehicle.faction == "Thunderbirds"
      assert vehicle.hard_points == 4
      assert vehicle.hull_current == 4
      assert vehicle.hull_threshold == 15
      assert vehicle.hyperdrive == "Primary: Class 2, Backup: None"
      assert vehicle.make == "YT-1300"
      assert vehicle.name == "Triumphant Failure"
      assert vehicle.notes == "A bunch of pretty good guys, you know?"
      assert vehicle.passengers == "2"
      assert vehicle.picture_url == "http://example.com/foo.gif"
      assert vehicle.price == "130,000"
      assert vehicle.rarity == "4(R)"
      assert vehicle.sensor_range == "Short"
      assert vehicle.silhouette == 4
      assert vehicle.special_features == "Painted \"Spectral Guise\" on the side"
      assert vehicle.speed == 5
      assert vehicle.strain_current == 6
      assert vehicle.strain_threshold == 15
      assert vehicle.type == "Ship"

      [first_attack, second_attack] = VehicleAttack.for_vehicle(vehicle.id)

      assert first_attack.display_order == 1
      assert first_attack.critical == "3"
      assert first_attack.damage == "7"
      assert first_attack.range == "Short"
      assert first_attack.firing_arc == "All"
      assert first_attack.specials == "Pierce 2"
      assert first_attack.weapon_name == "Dorsal Turbolaser"

      assert second_attack.display_order == 0
      assert second_attack.critical == "2"
      assert second_attack.damage == "11"
      assert second_attack.range == "Medium"
      assert second_attack.firing_arc == "Forward"
      assert second_attack.specials == "Blast 2"
      assert second_attack.weapon_name == "Concussion Missile"

      [attachment] = VehicleAttachment.for_vehicle(vehicle.id)

      assert attachment.base_modifiers == "Goes real fast like"
      assert attachment.hard_points_required == 0
      assert attachment.modifications == "pow!"
      assert attachment.name == "Boost mode"
    end

    it "redirects to the vehicle show page on success" do
      conn = authenticated_request(UserFactory.default_user, :post, "/v", %{ "vehicle" => %{"name" => "The Foobar"} })

      vehicle = Repo.all(Vehicle) |> Enum.at(0)

      assert is_redirect_to?(conn, "/v/#{vehicle.permalink}")
    end

    it "re-renders the page with an error when required fields are missing" do
      conn = authenticated_request(UserFactory.default_user, :post, "/v", %{
        "vehicle" => %{"name" => "", "faction" => "thin mints"},
        "attacks" => %{"0" => %{"critical" => "3", "damage" => "7", "display_order" => "1", "firing_arc" => "All", "id" => nil, "range" => "Short", "specials" => "Pierce 2", "weapon_name" => "Dorsal Turbolaser"}},
      })

      assert FlokiExt.element(conn, ".alert-danger") |> FlokiExt.text == "Name can't be blank"
      assert String.contains?(conn.resp_body, "thin mints")
      assert !is_nil(FlokiExt.element(conn, "[data-attack=0]"))
      assert !is_nil(FlokiExt.element(conn, "[data-attachment=0]"))
      assert String.contains?(conn.resp_body, "Dorsal Turbolaser")
    end

    it "doesn't create empty attacks or attachments" do
      authenticated_request(UserFactory.default_user, :post, "/v", %{
        "vehicle" => %{"name" => "The Foobar"},
        "attachments" => %{
          "0" => %{"base_modifiers" => "", "display_order" => "0", "hard_points_required" => "", "modifications" => "", "name" => ""}
        },
        "attacks" => %{
          "0" => %{"critical" => "", "damage" => "", "display_order" => "1", "firing_arc" => "", "id" => nil, "range" => "", "specials" => "", "weapon_name" => ""},
        },
      })
 
      vehicle = Repo.all(Vehicle) |> Enum.at(0)

      assert Enum.empty?(VehicleAttack.for_vehicle(vehicle.id))
      assert Enum.empty?(VehicleAttachment.for_vehicle(vehicle.id))
    end

    it "requires authentication" do
      conn = request(:post, "/v")

      assert requires_authentication?(conn)
    end
  end

  describe "edit" do
    it "renders the vehicle edit form" do
      vehicle = VehicleFactory.create_vehicle(user_id: UserFactory.default_user.id)

      vehicle_attack = %VehicleAttack{
        weapon_name: "ship claws",
        vehicle_id: vehicle.id
      } |> Repo.insert

      vehicle_attachment = %VehicleAttachment{
        name: "green shell",
        vehicle_id: vehicle.id
      } |> Repo.insert

      conn = authenticated_request(UserFactory.default_user, :get, "/v/#{vehicle.permalink}/edit")

      assert String.contains?(conn.resp_body, vehicle.name)
      assert String.contains?(conn.resp_body, vehicle_attack.weapon_name)
      assert String.contains?(conn.resp_body, vehicle_attachment.name)
    end

    it "requires authentication" do
      vehicle = VehicleFactory.create_vehicle

      conn = request(:get, "/v/#{vehicle.permalink}/edit")

      assert requires_authentication?(conn)
    end

    it "requires the current user to match the owning user" do
      owner = UserFactory.default_user
      other = UserFactory.create_user(username: "other")
      vehicle = VehicleFactory.create_vehicle(user_id: owner.id)

      conn = authenticated_request(other, :get, "/v/#{vehicle.permalink}/edit")

      assert is_redirect_to?(conn, "/")
    end
  end
end
