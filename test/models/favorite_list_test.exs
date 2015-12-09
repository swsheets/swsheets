defmodule EdgeBuilder.Models.FavoriteListTest do
  use EdgeBuilder.TestCase

  alias EdgeBuilder.Repo
  alias EdgeBuilder.Models.FavoriteList
  alias EdgeBuilder.Models.Favoriting
  alias Factories.CharacterFactory
  alias Factories.VehicleFactory

  it "adds a character" do
    list = %FavoriteList{name: "My List", characters: []}
    character = CharacterFactory.create_character(name: "Khron")
    orig_count = Repo.count(Favoriting)
    assert length(list.characters) == 0
    list = FavoriteList.add_character(list, character)
    assert Repo.count(Favoriting) == orig_count + 1
    assert length(list.characters) == 1
  end

  it "adds a vehicle" do
    list = %FavoriteList{name: "My List", vehicles: []}
    vehicle = VehicleFactory.create_vehicle(name: "Triumphant Failure")
    orig_count = Repo.count(Favoriting)
    assert length(list.vehicles) == 0
    list = FavoriteList.add_vehicle(list, vehicle)
    assert Repo.count(Favoriting) == orig_count + 1
    assert length(list.vehicles) == 1
  end
end
