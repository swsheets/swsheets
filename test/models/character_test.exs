defmodule EdgeBuilder.Models.CharacterTest do
  use EdgeBuilder.Test

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.Talent
  alias EdgeBuilder.Models.Attack
  alias EdgeBuilder.Models.BaseSkill
  alias EdgeBuilder.Models.CharacterSkill

  import Ecto.Query, only: [from: 2]

  describe "#full_character" do
    it "loads the character's talents" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter"
      } |> EdgeBuilder.Repo.insert

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
      } |> EdgeBuilder.Repo.insert

      attacks = [
        %Attack{weapon_name: "Holdout Blaster", character_id: character.id},
        %Attack{weapon_name: "Claws", character_id: character.id},
      ] |> Enum.map &EdgeBuilder.Repo.insert/1


      full_character = Character.full_character(character.id)
      assert full_character.attacks == attacks
    end

    it "loads skills that the character has" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter"
      } |> EdgeBuilder.Repo.insert

      base_skill = EdgeBuilder.Repo.one(from s in BaseSkill, where: s.name == "Athletics")

      character_skill = %CharacterSkill{
        character_id: character.id,
        base_skill_id: base_skill.id,
        is_career: true,
        rank: 3
      } |> EdgeBuilder.Repo.insert

      full_character = Character.full_character(character.id)
      assert Enum.member?(full_character.combined_character_skills, %{
        name: "Athletics",
        characteristic: "Brawn",
        base_skill_id: base_skill.id,
        id: character_skill.id,
        is_career: true,
        is_attack_skill: false,
        rank: 3
      })
    end

    it "loads blank skills that the character lacks" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter"
      } |> EdgeBuilder.Repo.insert

      base_skill = EdgeBuilder.Repo.one(from s in BaseSkill, where: s.name == "Athletics")

      full_character = Character.full_character(character.id)
      assert Enum.member?(full_character.combined_character_skills, %{
        name: "Athletics",
        characteristic: "Brawn",
        base_skill_id: base_skill.id,
        id: nil,
        is_career: false,
        is_attack_skill: false,
        rank: 0
      })
    end
  end
end
