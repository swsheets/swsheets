defmodule EdgeBuilder.Repositories.VehicleRepoTest do
  use EdgeBuilder.ModelCase

  alias EdgeBuilder.Repositories.VehicleRepo
  alias Factories.VehicleFactory
  alias Factories.UserFactory

  describe "all" do
    it "returns all vehicles by page in order" do
      vehicles = Enum.map(1..6, fn(n) ->
        VehicleFactory.create_vehicle(name: "Ship#{n}")
      end)

      %{entries: entries} = VehicleRepo.all()

      for v <- vehicles do
        assert Enum.any?(entries, &(&1.name == v.name)), "Expected to find vehicle #{v.name} in #{inspect(entries)}"
      end
    end

    it "populates permalinks accordingly" do
      VehicleFactory.create_vehicle(name: "ship")

      %{entries: [vehicle | _]} = VehicleRepo.all()

      assert vehicle.permalink == "#{vehicle.url_slug}-ship"
    end

    it "accepts optional page arguments" do
      Enum.map(1..11, fn(n) ->
        VehicleFactory.create_vehicle(name: "Ship#{n}")
      end)

      %{entries: first_page_entries} = VehicleRepo.all()
      assert Enum.count(first_page_entries) == 10

      %{entries: second_page_entries} = VehicleRepo.all(2)
      assert Enum.count(second_page_entries) == 1
    end
  end

  describe "recent" do
    it "returns the most recent five vehicles" do
      for _ <- 1..6 do
        VehicleFactory.create_vehicle
      end

      vehicles = VehicleRepo.recent()

      assert Enum.count(vehicles) == 5
      assert Enum.all?(vehicles, &match?(%EdgeBuilder.Models.Vehicle{}, &1))
    end
  end

  describe "all_for_user" do
    it "returns all vehicles for just one user" do
      user1 = UserFactory.default_user
      for _ <- 1..6 do
        VehicleFactory.create_vehicle(user_id: user1.id)
      end
      {:ok, user2} = UserFactory.create_user
      VehicleFactory.create_vehicle(user_id: user2.id)

      vehicles = VehicleRepo.all_for_user(user1.id)

      assert Enum.count(vehicles) == 6
      assert Enum.all?(vehicles, &(&1.user_id == user1.id))
    end
  end

  describe "full_vehicle" do
    it "finds a vehicle by url slug" do
      vehicle = VehicleFactory.create_vehicle

      found_vehicle = VehicleRepo.full_vehicle("#{vehicle.url_slug}-does-not-matter")

      assert vehicle.id == found_vehicle.id
    end

    it "preloads all child records" do
      %{id: vehicle_id, url_slug: url_slug} = VehicleFactory.create_vehicle
      Repo.insert!(%EdgeBuilder.Models.VehicleAttachment{vehicle_id: vehicle_id, name: "Attachment"})
      Repo.insert!(%EdgeBuilder.Models.VehicleAttack{vehicle_id: vehicle_id, weapon_name: "Attack"})

      found_vehicle = VehicleRepo.full_vehicle("#{url_slug}-does-not-matter")

      assert match?(
        %{
          id: ^vehicle_id,
          vehicle_attachments: [%EdgeBuilder.Models.VehicleAttachment{}],
          vehicle_attacks: [%EdgeBuilder.Models.VehicleAttack{}],
        }, found_vehicle)
    end
  end
end
