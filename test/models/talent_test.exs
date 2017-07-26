defmodule EdgeBuilder.Models.TalentTest do
  use EdgeBuilder.ModelCase

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.Talent
  alias EdgeBuilder.Repo

  describe "for_character" do
    it "retrieves all talents for a character" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter"
      } |> Repo.insert!

      greedos_talent = %Talent{
        name: "Witty Repartee",
        character_id: character.id
      } |> Repo.insert!

      _different_talent = %Talent{
        name: "Quick Draw",
        character_id: character.id + 1
      } |> Repo.insert!

      assert Talent.for_character(character.id) == [greedos_talent]
    end
  end
end
