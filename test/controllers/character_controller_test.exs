defmodule EdgeBuilder.Controllers.CharacterControllerTest do
  use EdgeBuilder.ControllerTest

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.Talent
  alias EdgeBuilder.Models.Attack
  alias EdgeBuilder.Models.BaseSkill
  alias EdgeBuilder.Models.CharacterSkill
  import Ecto.Query, only: [from: 2]

  describe "new" do
    it "renders the character edit form for a new character" do
      conn = request(:get, "/characters/new")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, "New Character")
    end
  end

  describe "create" do
    it "creates a character" do

      base_skills = BaseSkill.all
        |> Enum.reject(&(&1.name == "Athletics"))
        |> Enum.with_index
        |> Enum.map(fn {skill, index} ->
            {index, %{"base_skill_id" => skill.id, "rank" => "0"}}
          end)
        |> Enum.into(%{})

      skills_with_user_edit = base_skills
        |> Map.put("Athletics", %{"base_skill_id" => BaseSkill.by_name("Athletics").id, "rank" => "3", "is_career" => "on"})

      request(:post, "/characters", %{
        "character" => %{
          "name" => "Greedo",
          "species" => "Rodian",
          "career" => "Bounty Hunter",
          "credits" => "3000",
          "defense_melee" => "1",
          "defense_ranged" => "2",
          "encumbrance" => "5 / 8",
          "motivation" => "Kill some dudes",
          "obligation" => "(10 pts) Has to kill some dudes",
          "soak" => "3",
          "specializations" => "Hired Gun",
          "strain_current" => "4",
          "strain_threshold" => "5",
          "wounds_current" => "",
          "wounds_threshold" => "7",
          "xp_available" => "100",
          "xp_total" => "200",
          "background" => "A regular Rodian, you know",
          "description" => "Green",
          "other_notes" => "Not the best",
        },
        "attacks" => %{
          "0" => %{"critical" => "3", "damage" => "4", "range" => "Short", "base_skill_id" => BaseSkill.by_name("Ranged: Light").id, "specials" => "Stun Setting", "weapon_name" => "Holdout Blaster"},
          "1" => %{"id" => "", "critical" => "5", "damage" => "+1", "range" => "Engaged", "base_skill_id" => BaseSkill.by_name("Brawl").id, "specials" => "", "weapon_name" => "Claws"}
        },
        "skills" => skills_with_user_edit,
        "talents" => %{
          "0" => %{"book_and_page" => "EotE p25", "description" => "Draw as incidental", "name" => "Quick Draw"},
          "1" => %{"book_and_page" => "DC p200", "description" => "Upgrade all checks by one", "name" => "Adversary 1"}
        },
      })

      character = EdgeBuilder.Repo.all(Character) |> Enum.at(0)

      assert character.name == "Greedo"
      assert character.species == "Rodian"
      assert character.career == "Bounty Hunter"
      assert character.credits == 3000
      assert character.defense_melee == 1
      assert character.defense_ranged == 2
      assert character.encumbrance == "5 / 8"
      assert character.motivation == "Kill some dudes"
      assert character.obligation == "(10 pts) Has to kill some dudes"
      assert character.soak == 3
      assert character.specializations == "Hired Gun"
      assert character.strain_current == 4
      assert character.strain_threshold == 5
      assert is_nil(character.wounds_current)
      assert character.wounds_threshold == 7
      assert character.xp_available == 100
      assert character.xp_total == 200
      assert character.background == "A regular Rodian, you know"
      assert character.description == "Green"
      assert character.other_notes == "Not the best"

      [first_attack, second_attack] = Attack.for_character(character.id)

      assert first_attack.critical == "3"
      assert first_attack.damage == "4"
      assert first_attack.range == "Short"
      assert first_attack.base_skill_id == BaseSkill.by_name("Ranged: Light").id
      assert first_attack.specials == "Stun Setting"
      assert first_attack.weapon_name == "Holdout Blaster"
 
      assert second_attack.critical == "5"
      assert second_attack.damage == "+1"
      assert second_attack.range == "Engaged"
      assert second_attack.base_skill_id == BaseSkill.by_name("Brawl").id
      assert second_attack.specials == nil
      assert second_attack.weapon_name == "Claws"

      [first_talent, second_talent] = Talent.for_character(character.id)

      assert first_talent.book_and_page == "EotE p25"
      assert first_talent.description == "Draw as incidental"
      assert first_talent.name == "Quick Draw"

      assert second_talent.book_and_page == "DC p200"
      assert second_talent.description == "Upgrade all checks by one"
      assert second_talent.name == "Adversary 1"
      
      [character_skill] = CharacterSkill.for_character(character.id)

      assert character_skill.base_skill_id == BaseSkill.by_name("Athletics").id
      assert character_skill.is_career
      assert character_skill.rank == 3
    end
  end

  describe "edit" do
    it "renders the character edit form" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter"
      } |> EdgeBuilder.Repo.insert

      character_skill = %CharacterSkill{
        base_skill_id: BaseSkill.by_name("Athletics").id,
        rank: 4,
        character_id: character.id
      } |> EdgeBuilder.Repo.insert

      talent = %Talent{
        name: "Quick Draw",
        character_id: character.id
      } |> EdgeBuilder.Repo.insert

      attack = %Attack{
        weapon_name: "Holdout Blaster",
        character_id: character.id
      } |> EdgeBuilder.Repo.insert

      conn = request(:get, "/characters/#{character.id}/edit")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, character.name)
      assert String.contains?(conn.resp_body, character_skill.rank |> to_string)
      assert String.contains?(conn.resp_body, talent.name)
      assert String.contains?(conn.resp_body, attack.weapon_name)
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

      request(:put, "/characters/#{character.id}", %{"character" => %{
        "xp_total" => "60",
        "xp_available" => "",
        "description" =>  "tbd"
      }})

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

      request(:put, "/characters/#{character.id}", %{"character" => %{}, "talents" => %{
        "0" => %{"book_and_page" => "DC p43", "description" => "Do stuff", "id" => talent.id, "name" => "Awesome Guy"}
      }})

      [talent] = Talent.for_character(character.id)

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

      request(:put, "/characters/#{character.id}", %{"character" => %{}, "talents" => %{
        "0" => %{"book_and_page" => "DC p43", "description" => "Do stuff", "name" => "Awesome Guy"}
      }})

      [talent] = Talent.for_character(character.id)

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

      request(:put, "/characters/#{character.id}", %{"character" => %{}})

      talents = Talent.for_character(character.id)

      assert Enum.count(talents) == 0
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

      request(:put, "/characters/#{character.id}", %{"character" => %{}, "attacks" => %{
        "0" => %{"weapon_name" => "Claws", "range" => "Engaged", "id" => attack.id}
      }})

      [attack] = Attack.for_character(character.id)

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

      request(:put, "/characters/#{character.id}", %{"character" => %{}, "attacks" => %{
        "0" => %{"weapon_name" => "Claws", "range" => "Engaged", "base_skill_id" => base_skill.id}
      }})

      [attack] = Attack.for_character(character.id)

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

      request(:put, "/characters/#{character.id}", %{"character" => %{}})

      attacks = Attack.for_character(character.id)

      assert Enum.count(attacks) == 0
      assert EdgeBuilder.Repo.all(Attack) |> Enum.count == 0
    end

    it "creates new skills when they differ from default values" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter",
      } |> EdgeBuilder.Repo.insert

      base_skill = EdgeBuilder.Repo.one(from bs in BaseSkill, where: bs.name == "Athletics")

      request(:put, "/characters/#{character.id}", %{"character" => %{}, "skills" => %{"0" => %{"base_skill_id" => base_skill.id, "rank" => 1, "is_career" => "on"}}})

      [character_skill] = CharacterSkill.for_character(character.id)

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

      request(:put, "/characters/#{character.id}", %{"character" => %{}, "skills" => %{"0" => %{"base_skill_id" => base_skill.id, "rank" => 0}}})

      assert Enum.count(CharacterSkill.for_character(character.id)) == 0
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

      request(:put, "/characters/#{character.id}", %{"character" => %{}, "skills" => %{"0" => %{"base_skill_id" => base_skill.id, "rank" => 0, "id" => original_character_skill.id}}})

      [character_skill] = CharacterSkill.for_character(character.id)

      assert character_skill.id == original_character_skill.id
      assert character_skill.rank == 0
    end
  end
end
