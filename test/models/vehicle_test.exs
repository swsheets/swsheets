defmodule EdgeBuilder.Models.VehicleTest do
  use EdgeBuilder.ModelCase

  alias Factories.VehicleFactory
  alias EdgeBuilder.Models.Vehicle
  alias EdgeBuilder.Repo

  describe "url_slug" do
    it "has an 9 vehicle lower-case slug after creation" do
      vehicle = VehicleFactory.create_vehicle

      assert String.match?(vehicle.url_slug, ~r/[0-9a-z]{9}/)
    end
  end

  describe "permalink" do
    it "is a combination of the vehicle name and url_slug" do
      vehicle = VehicleFactory.create_vehicle(name: "steve")

      assert vehicle.permalink == "#{vehicle.url_slug}-steve"
    end

    it "works regardless of special vehicles in the vehicle's name" do
      vehicle = VehicleFactory.create_vehicle(name: "K'l<a> <p>")

      assert vehicle.permalink == "#{vehicle.url_slug}-k-l-a---p-"
    end

    it "trims very long names" do
      vehicle = VehicleFactory.create_vehicle(name: "thisstringisthirtyonevehicles")

      assert vehicle.permalink == "#{vehicle.url_slug}-thisstringisthi"
    end

    @tag :skip
    it "works on load too" do
      vehicle = VehicleFactory.create_vehicle(name: "steve")
      vehicle = Repo.get(Vehicle, vehicle.id)

      assert vehicle.permalink == "#{vehicle.url_slug}-steve"
    end
  end

  describe "full_vehicle" do
    it "finds a vehicle by url slug" do
      vehicle = VehicleFactory.create_vehicle

      found_vehicle = Vehicle.full_vehicle("#{vehicle.url_slug}-does-not-matter")

      assert vehicle.id == found_vehicle.id
    end
  end
end

