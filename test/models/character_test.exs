defmodule EdgeBuilder.Models.CharacterTest do
  use ExSpec

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.Talent

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
  end
end
