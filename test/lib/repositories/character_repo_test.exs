defmodule EdgeBuilder.Repositories.CharacterRepoTest do
  use EdgeBuilder.ModelCase

  alias EdgeBuilder.Repositories.CharacterRepo
  alias Factories.CharacterFactory
  alias Factories.UserFactory

  describe "all" do
    it "returns all characters by page in order" do
      characters = Enum.map(1..6, fn(n) ->
        CharacterFactory.create_character(name: "Hero#{n}")
      end)

      %{entries: entries} = CharacterRepo.all()

      for c <- characters do
        assert Enum.any?(entries, &(&1.name == c.name)), "Expected to find character #{c.name} in #{inspect(entries)}"
      end
    end

    it "populates permalinks accordingly" do
      CharacterFactory.create_character(name: "steve")

      %{entries: [character | _]} = CharacterRepo.all()

      assert character.permalink == "#{character.url_slug}-steve"
    end

    it "accepts optional page arguments" do
      Enum.map(1..11, fn(n) ->
        CharacterFactory.create_character(name: "Hero#{n}")
      end)

      %{entries: first_page_entries} = CharacterRepo.all()
      assert Enum.count(first_page_entries) == 10

      %{entries: second_page_entries} = CharacterRepo.all(2)
      assert Enum.count(second_page_entries) == 1
    end
  end

  describe "recent" do
    it "returns the most recent five characters" do
      for _ <- 1..6 do
        CharacterFactory.create_character
      end

      characters = CharacterRepo.recent()

      assert Enum.count(characters) == 5
      assert Enum.all?(characters, &match?(%EdgeBuilder.Models.Character{}, &1))
    end
  end

  describe "all_for_user" do
    it "returns all characters for just one user" do
      user1 = UserFactory.default_user
      for _ <- 1..6 do
        CharacterFactory.create_character(user_id: user1.id)
      end
      {:ok, user2} = UserFactory.create_user
      CharacterFactory.create_character(user_id: user2.id)

      characters = CharacterRepo.all_for_user(user1.id)

      assert Enum.count(characters) == 6
      assert Enum.all?(characters, &(&1.user_id == user1.id))
    end
  end

  describe "full_character" do
    it "finds a character by url slug" do
      character = CharacterFactory.create_character

      found_character = CharacterRepo.full_character("#{character.url_slug}-does-not-matter")

      assert character.id == found_character.id
    end

    it "preloads all child records" do
      %{id: character_id, url_slug: url_slug} = CharacterFactory.create_character
      Repo.insert!(%EdgeBuilder.Models.Attack{character_id: character_id, weapon_name: "Claws"})
      Repo.insert!(%EdgeBuilder.Models.Talent{character_id: character_id, name: "Be Awesome"})
      Repo.insert!(%EdgeBuilder.Models.CharacterSkill{
        base_skill_id: EdgeBuilder.Models.BaseSkill.by_name("Athletics").id,
        character_id: character_id
      })
      force_power = Repo.insert!(%EdgeBuilder.Models.ForcePower{character_id: character_id, name: "Force Push"})
      Repo.insert!(%EdgeBuilder.Models.ForcePowerUpgrade{force_power_id: force_power.id, name: "Buffout"})

      found_character = CharacterRepo.full_character("#{url_slug}-does-not-matter")

      assert match?(
        %{
          id: ^character_id,
          talents: [%EdgeBuilder.Models.Talent{}],
          attacks: [%EdgeBuilder.Models.Attack{}],
          character_skills: [%EdgeBuilder.Models.CharacterSkill{}],
          force_powers: [%EdgeBuilder.Models.ForcePower{
              force_power_upgrades: [%EdgeBuilder.Models.ForcePowerUpgrade{}]}
          ]
        }, found_character)
    end
  end
end
