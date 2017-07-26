defmodule EdgeBuilder.Models.AttackTest do
  use EdgeBuilder.ModelCase

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.Attack
  alias EdgeBuilder.Repo

  describe "for_character" do
    it "retrieves all attacks for a character" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter"
      } |> Repo.insert!

      greedos_attack = %Attack{
        weapon_name: "nunchuks",
        character_id: character.id
      } |> Repo.insert!

      _different_attack = %Attack{
        weapon_name: "switchblade",
        character_id: character.id + 1
      } |> Repo.insert!

      assert Attack.for_character(character.id) == [greedos_attack]
    end
  end
end
