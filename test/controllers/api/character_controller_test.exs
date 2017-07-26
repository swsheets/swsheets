defmodule EdgeBuilder.Controllers.API.CharacterControllerTest do
  use EdgeBuilder.ConnCase

  alias Factories.CharacterFactory
  alias Factories.UserFactory
  alias EdgeBuilder.Repo
  alias EdgeBuilder.Models.Character

  describe "update" do
    it "updates basic characteristics of a character" do
      character = CharacterFactory.create_character(user_id: UserFactory.default_user.id, strain_current: 0)

      conn = build_conn() |> authenticate_as(UserFactory.default_user) |> json_put("/api/characters/#{character.permalink}", %{character: %{strain_current: 5}})

      assert conn.status == 200
      character = Repo.get(Character, character.id)

      assert character.strain_current == 5
    end

    it "returns errors properly" do
      character = CharacterFactory.create_character(user_id: UserFactory.default_user.id, strain_current: 0)

      conn = build_conn() |> authenticate_as(UserFactory.default_user) |> json_put("/api/characters/#{character.permalink}", %{character: %{name: ""}})

      assert conn.resp_body |> Poison.decode! == %{"errors" => %{"name" => "can't be blank"}}
    end

    it "requires authentication" do
      conn = build_conn() |> json_put("/api/characters/doesnt-matter")

      assert requires_authentication?(conn)
    end

    it "requires the current user to match the owning user" do
      owner = UserFactory.default_user
      other = UserFactory.create_user!(username: "other")
      character = CharacterFactory.create_character(user_id: owner.id)

      conn = build_conn() |> authenticate_as(other) |> json_put("/api/characters/#{character.permalink}", %{character: %{strain_current: 5}})

      assert conn.status == 403
    end
  end
end
