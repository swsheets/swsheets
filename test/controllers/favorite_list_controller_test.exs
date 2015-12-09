defmodule EdgeBuilder.Controllers.FavoriteListControllerTest do
  use EdgeBuilder.ConnCase

  alias Factories.CharacterFactory
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
end
