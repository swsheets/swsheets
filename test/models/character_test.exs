defmodule EdgeBuilder.Models.CharacterTest do
  use EdgeBuilder.ModelCase

  alias Factories.CharacterFactory
  alias Factories.UserFactory
  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Repo

  describe "url_slug" do
    it "has an 9 character lower-case slug after creation" do
      character = CharacterFactory.create_character()

      assert String.match?(character.url_slug, ~r/[0-9a-z]{9}/)
    end
  end

  describe "permalink" do
    it "is a combination of the character name and url_slug" do
      character = CharacterFactory.create_character(name: "steve")

      assert character.permalink == "#{character.url_slug}-steve"
    end

    it "works regardless of special characters in the character's name" do
      character = CharacterFactory.create_character(name: "K'l<a> <p>")

      assert character.permalink == "#{character.url_slug}-k-l-a---p-"
    end

    it "trims very long names" do
      character = CharacterFactory.create_character(name: "thisstringisthirtyonecharacters")

      assert character.permalink == "#{character.url_slug}-thisstringisthi"
    end

    @tag :skip
    it "works on load too" do
      character = CharacterFactory.create_character(name: "steve")
      character = Repo.get(Character, character.id)

      assert character.permalink == "#{character.url_slug}-steve"
    end
  end

  describe "portrait_url" do
    @valid_attrs %{
      "name" => "Matwe",
      "species" => "Human",
      "career" => "Smuggler",
      "system" => "eote"
    }

    it "changes imgur page url to image url" do
      character =
        CharacterFactory.create_character(portrait_url: "https://imgur.com/gallery/OjCH1Th")

      assert character.portrait_url == "https://i.imgur.com/OjCH1Th.jpg"
    end

    it "does not allow HTTP images" do
      attrs = Map.put(@valid_attrs, "portrait_url", "http://imgur.com/gallery/OjCH1Th")
      changeset = Character.changeset(%Character{}, UserFactory.default_user().id, attrs)

      assert {:portrait_url, {"must begin with \"https://\"", [validation: :format]}} in changeset.errors
    end

    it "does not allow random junk" do
      attrs = Map.put(@valid_attrs, "portrait_url", "gobbdly gobbldy https://")
      changeset = Character.changeset(%Character{}, UserFactory.default_user().id, attrs)

      assert {:portrait_url, {"must begin with \"https://\"", [validation: :format]}} in changeset.errors
    end
  end
end
