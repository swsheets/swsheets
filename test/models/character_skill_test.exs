defmodule EdgeBuilder.Models.CharacterSkillTest do
  use EdgeBuilder.Test

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.CharacterSkill
  alias EdgeBuilder.Models.BaseSkill
  alias EdgeBuilder.Repo

  describe "for_character" do
    it "retrieves all character_skills for a character" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter"
      } |> Repo.insert

      base_skill = BaseSkill.all |> Enum.at(0)

      greedos_skill = %CharacterSkill{
        rank: 2,
        base_skill_id: base_skill.id,
        character_id: character.id
      } |> Repo.insert

      _different_skill = %CharacterSkill{
        rank: 3,
        base_skill_id: base_skill.id,
        character_id: character.id + 1
      } |> Repo.insert

      assert CharacterSkill.for_character(character.id) == [greedos_skill]
    end
  end

  describe "add_missing_defaults" do
    it "takes a collection of character skills and ensures all base skills are represented" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter"
      } |> Repo.insert

      base_skill = BaseSkill.all |> Enum.at(0)

      greedos_skill = %CharacterSkill{
        rank: 2,
        base_skill_id: base_skill.id,
        character_id: character.id
      } |> Repo.insert

      all_character_skills = CharacterSkill.add_missing_defaults([greedos_skill])

      assert Enum.count(all_character_skills) == Enum.count(BaseSkill.all)

      matching_character_skill = Enum.find(all_character_skills, &(&1.base_skill_id == base_skill.id))     
      assert matching_character_skill.id == greedos_skill.id
      assert matching_character_skill.rank == greedos_skill.rank
      
      unmatched_character_skill = Enum.find(all_character_skills, &(&1.base_skill_id != base_skill.id))
      assert is_nil(unmatched_character_skill.id)
      assert unmatched_character_skill.rank == 0
    end
  end

  describe "is_default_changeset?" do
    it "returns false when the changeset has a non-default value" do
      changeset = %CharacterSkill{
        base_skill_id: 1,
        rank: 4
      } |> CharacterSkill.changeset

      refute CharacterSkill.is_default_changeset?(changeset)
    end

    it "returns true when a changeset has default non-assocation values and has not yet been persisted" do
      changeset = %CharacterSkill{
        character_id: 1,
        base_skill_id: 1,
        rank: 0
      } |> CharacterSkill.changeset

      assert CharacterSkill.is_default_changeset?(changeset)
    end
  end
end
