defmodule EdgeBuilder.Controllers.FavoriteListControllerTest do
  use EdgeBuilder.ConnCase

  alias Factories.CharacterFactory
  alias Factories.VehicleFactory
  alias Factories.UserFactory
  alias EdgeBuilder.Models.FavoriteList
  alias EdgeBuilder.Repo

  describe "add_character" do
    it "creates a list and associates the character" do
      character = CharacterFactory.create_character
      conn() |> authenticate_as(UserFactory.default_user) |> post("/user/favorite_lists/add_character", %{
        "name" => "My List",
        "character_id" => character.id
      })

      list = Repo.all(FavoriteList) |> Enum.at(0) |> Repo.preload :characters
      assert list.name == "My List"
      assert length(list.characters) == 1
      assert Enum.at(list.characters, 0) == character
    end
  end

  describe "add_vehicle" do
    it "creates a list and associates the vehicle" do
      vehicle = VehicleFactory.create_vehicle
      conn() |> authenticate_as(UserFactory.default_user) |> post("/user/favorite_lists/add_vehicle", %{
        "name" => "My List",
        "vehicle_id" => vehicle.id
      })

      list = Repo.all(FavoriteList) |> Enum.at(0) |> Repo.preload :vehicles
      assert list.name == "My List"
      assert length(list.vehicles) == 1
      assert Enum.at(list.vehicles, 0) == vehicle
    end
  end
end
