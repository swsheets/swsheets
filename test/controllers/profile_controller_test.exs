defmodule EdgeBuilder.Controllers.ProfileControllerTest do
  use EdgeBuilder.ControllerTest

  alias Factories.UserFactory
  alias Factories.CharacterFactory

  describe "show" do
    it "shows the username" do
      user = UserFactory.create_user

      conn = request(:get, "/u/#{user.username}")

      assert String.contains?(conn.resp_body, user.username)
    end

    test "shows a number of characters created" do
      for {count, text} <- [{0, "0 Characters"}, {1, "1 Character"}, {2, "2 Characters"}] do
        user = UserFactory.create_user
        Stream.repeatedly(fn () -> CharacterFactory.create_character(user_id: user.id) end) |> Enum.take(count)

        conn = request(:get, "/u/#{user.username}")

        assert String.contains?(conn.resp_body, text), "Expected to find #{text}"
      end
    end

    it "shows a list of characters they have created" do
      user = UserFactory.create_user
      characters = [CharacterFactory.create_character(user_id: user.id), CharacterFactory.create_character(user_id: user.id)]

      conn = request(:get, "/u/#{user.username}")

      for character <- characters do
        assert String.contains?(conn.resp_body, character.permalink)
      end
    end
  end
end
