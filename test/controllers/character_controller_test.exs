defmodule EdgeBuilder.Controllers.CharacterControllerTest do
  use EdgeBuilder.ControllerTest

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.Talent
  alias EdgeBuilder.Models.Attack
  alias EdgeBuilder.Models.BaseSkill
  alias EdgeBuilder.Models.CharacterSkill
  import Ecto.Query, only: [from: 2]

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

    it "updates the character's prior talents" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter",
      } |> EdgeBuilder.Repo.insert

      talent = %Talent{
        name: "Quick Draw",
        book_and_page: "EotE Core p145",
        description: "Draws a gun quickly",
        character_id: character.id
      } |> EdgeBuilder.Repo.insert

      conn = request(:put, "/characters/#{character.id}", %{"character" => %{}, "talents" => %{
        "0" => %{"book_and_page" => "DC p43", "description" => "Do stuff", "id" => talent.id, "name" => "Awesome Guy"}
      }})

      assert conn.status == 200

      character = Character.full_character(character.id)

      assert Enum.count(character.talents) == 1
      talent = Enum.at(character.talents, 0)

      assert talent.name == "Awesome Guy"
      assert talent.description == "Do stuff"
      assert talent.book_and_page == "DC p43"
    end

    it "creates new talents for the character" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter",
      } |> EdgeBuilder.Repo.insert

      conn = request(:put, "/characters/#{character.id}", %{"character" => %{}, "talents" => %{
        "0" => %{"book_and_page" => "DC p43", "description" => "Do stuff", "name" => "Awesome Guy"}
      }})

      assert conn.status == 200

      character = Character.full_character(character.id)

      assert Enum.count(character.talents) == 1
      talent = Enum.at(character.talents, 0)

      assert talent.name == "Awesome Guy"
      assert talent.description == "Do stuff"
      assert talent.book_and_page == "DC p43"
    end

    it "deletes any talents for that character that were not specified in the update" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter",
      } |> EdgeBuilder.Repo.insert

      %Talent{
        name: "Quick Draw",
        book_and_page: "EotE Core p145",
        description: "Draws a gun quickly",
        character_id: character.id
      } |> EdgeBuilder.Repo.insert

      conn = request(:put, "/characters/#{character.id}", %{"character" => %{}})

      assert conn.status == 200

      character = Character.full_character(character.id)

      assert Enum.count(character.talents) == 0
      assert EdgeBuilder.Repo.all(Talent) |> Enum.count == 0
    end

    it "updates the character's prior attacks" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter",
      } |> EdgeBuilder.Repo.insert

      attack = %Attack{
        weapon_name: "Holdout Blaster",
        range: "Short",
        character_id: character.id
      } |> EdgeBuilder.Repo.insert

      conn = request(:put, "/characters/#{character.id}", %{"character" => %{}, "attacks" => %{
        "0" => %{"weapon_name" => "Claws", "range" => "Engaged", "id" => attack.id}
      }})

      assert conn.status == 200

      character = Character.full_character(character.id)

      assert Enum.count(character.attacks) == 1
      attack = Enum.at(character.attacks, 0)

      assert attack.weapon_name == "Claws"
      assert attack.range == "Engaged"
    end

    it "creates new attacks for the character" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter",
      } |> EdgeBuilder.Repo.insert

      base_skill = EdgeBuilder.Repo.all(BaseSkill) |> Enum.at(0)

      conn = request(:put, "/characters/#{character.id}", %{"character" => %{}, "attacks" => %{
        "0" => %{"weapon_name" => "Claws", "range" => "Engaged", "base_skill_id" => base_skill.id}
      }})

      assert conn.status == 200

      character = Character.full_character(character.id)

      assert Enum.count(character.attacks) == 1
      attack = Enum.at(character.attacks, 0)

      assert attack.weapon_name == "Claws"
      assert attack.range == "Engaged"
      assert attack.base_skill_id == base_skill.id
    end

    it "deletes any attacks for that character that were not specified in the update" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter",
      } |> EdgeBuilder.Repo.insert

      %Attack{
        weapon_name: "Holdout Blaster",
        range: "Short",
        character_id: character.id
      } |> EdgeBuilder.Repo.insert

      conn = request(:put, "/characters/#{character.id}", %{"character" => %{}})

      assert conn.status == 200

      character = Character.full_character(character.id)

      assert Enum.count(character.attacks) == 0
      assert EdgeBuilder.Repo.all(Attack) |> Enum.count == 0
    end

    it "creates new skills when they differ from default values" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter",
      } |> EdgeBuilder.Repo.insert

      base_skill = EdgeBuilder.Repo.one(from bs in BaseSkill, where: bs.name == "Athletics")

      conn = request(:put, "/characters/#{character.id}", %{"character" => %{}, "skills" => %{"0" => %{"base_skill_id" => base_skill.id, "rank" => 1, "is_career" => "on"}}})

      assert conn.status == 200

      character = Character.full_character(character.id)
      assert Enum.count(character.character_skills) == 1

      character_skill = Enum.at(character.character_skills,0)
      assert character_skill.rank == 1
      assert character_skill.is_career
      assert character_skill.base_skill_id == base_skill.id
    end

    it "does not create new skills for skills that are not persisted and that do not differ from defaults" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter",
      } |> EdgeBuilder.Repo.insert

      base_skill = EdgeBuilder.Repo.one(from bs in BaseSkill, where: bs.name == "Athletics")

      conn = request(:put, "/characters/#{character.id}", %{"character" => %{}, "skills" => %{"0" => %{"base_skill_id" => base_skill.id, "rank" => 0}}})

      assert conn.status == 200

      character = Character.full_character(character.id)

      assert Enum.count(character.character_skills) == 0
    end

    it "updates and does not delete previously-saved skills that are set back to the default" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter",
      } |> EdgeBuilder.Repo.insert

      base_skill = EdgeBuilder.Repo.one(from bs in BaseSkill, where: bs.name == "Athletics")

      original_character_skill = %CharacterSkill{
        base_skill_id: base_skill.id,
        character_id: character.id,
        rank: 5
      } |> EdgeBuilder.Repo.insert

      conn = request(:put, "/characters/#{character.id}", %{"character" => %{}, "skills" => %{"0" => %{"base_skill_id" => base_skill.id, "rank" => 0, "id" => original_character_skill.id}}})

      assert conn.status == 200

      character = Character.full_character(character.id)

      character_skill = Enum.at(character.character_skills, 0)

      assert character_skill.id == original_character_skill.id
      assert character_skill.rank == 0
    end
  end
end
