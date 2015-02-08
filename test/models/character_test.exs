defmodule EdgeBuilder.Models.CharacterTest do
  use EdgeBuilder.Test

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.Talent
  alias EdgeBuilder.Models.Attack

  describe "#full_character" do
    it "loads the character's talents" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter"
      } |> EdgeBuilder.Repo.insert()

      talents = [
        %Talent{name: "Quick Draw", character_id: character.id},
        %Talent{name: "Adversary 1", character_id: character.id},
      ] |> Enum.map &EdgeBuilder.Repo.insert/1


      full_character = Character.full_character(character.id)
      assert full_character.talents == talents
    end

    it "loads the character's attacks" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter"
      } |> EdgeBuilder.Repo.insert()

      attacks = [
        %Attack{weapon_name: "Holdout Blaster", character_id: character.id},
        %Attack{weapon_name: "Claws", character_id: character.id},
      ] |> Enum.map &EdgeBuilder.Repo.insert/1


      full_character = Character.full_character(character.id)
      assert full_character.attacks == attacks
    end
  end
end
