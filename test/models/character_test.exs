defmodule EdgeBuilder.Models.CharacterTest do
  use EdgeBuilder.Test

  alias Factories.CharacterFactory

  describe "url_slug" do
    it "has an 9 character lower-case slug after creation" do
      character = CharacterFactory.create_character

      assert String.match?(character.url_slug, ~r/[0-9a-z]{9}/)
    end
  end
end
