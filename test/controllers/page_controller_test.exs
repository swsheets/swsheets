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

    it "shows a message if your password has just been reset" do
      conn = request(:get, "/", %{}, fn(c) -> Plug.Conn.put_session(c, "phoenix_flash", %{"has_reset_password" => true}) end)

      assert String.contains?(conn.resp_body, "Your password has been reset and you are now logged in. Welcome back!")
    end

    it "shows no message if your password has not just been reset" do
      conn = request(:get, "/")

      assert !String.contains?(conn.resp_body, "Your password has been reset and you are now logged in. Welcome back!")
    end
  end
end
