defmodule EdgeBuilder.Controllers.CharacterControllerTest do
  use EdgeBuilder.ControllerTest

  alias EdgeBuilder.Models.Character

  describe "edit" do
    it "renders the character edit form" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter"
      } |> EdgeBuilder.Repo.insert

      conn = request(:get, "/characters/#{character.id}/edit")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, "Greedo")
      assert String.contains?(conn.resp_body, "Rodian")
    end
  end

  describe "update" do
    it "updates the character's basic attributes" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter"
      } |> EdgeBuilder.Repo.insert

      conn = request(:put, "/characters/#{character.id}", %{"character" => %{"name" => "Do'mesh", "species" => "Twi'lek"}})

      assert conn.status == 200

      character = EdgeBuilder.Repo.get(Character, character.id)

      assert character.name == "Do'mesh"
      assert character.species == "Twi'lek"
    end

    it "updates the character's optional attributes" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter",
        xp_total: 50,
        xp_available: 10,
        description: "A slow shooter"
      } |> EdgeBuilder.Repo.insert

      conn = request(:put, "/characters/#{character.id}", %{"character" => %{
        "xp_total" => "60",
        "xp_available" => "",
        "description" =>  "tbd"
      }})

      assert conn.status == 200

      character = EdgeBuilder.Repo.get(Character, character.id)

      assert character.xp_total == 60
      assert is_nil(character.xp_available)
      assert character.description == "tbd"
      assert is_nil(character.other_notes)
    end
  end
end
