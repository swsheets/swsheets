defmodule EdgeBuilder.Controllers.PageControllerTest do
  use EdgeBuilder.ControllerTest

  alias Factories.UserFactory
  alias Factories.CharacterFactory

  describe "index" do
    it "shows a list of characters" do
      user = UserFactory.default_user

      characters = [
        CharacterFactory.create_character(name: "Frank", user_id: user.id),
        CharacterFactory.create_character(name: "Boba Fett", user_id: user.id)
      ]

      conn = request(:get, "/")

      for character <- characters do
        assert String.contains?(conn.resp_body, character.name)
      end
    end
  end
end
