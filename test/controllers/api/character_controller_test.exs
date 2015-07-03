defmodule EdgeBuilder.Controllers.API.CharacterControllerTest do
  use EdgeBuilder.ConnCase

  alias Factories.CharacterFactory
  alias Factories.UserFactory

  describe "update" do
    it "updates basic characteristics of a character" do
      character = CharacterFactory.create_character(user_id: UserFactory.default_user.id)

      conn = conn() |> get("/") |> put_req_header("content-type", "application/json") |> put("/api/characters/#{character.permalink}", %{strain_current: 5} |> Poison.encode!)

      assert conn.status == 200
      assert conn.resp_body |> Poison.decode! == %{"strain_current" => 5}
    end

    it "updates basic characteristics of a character without recycling a connection" do
      character = CharacterFactory.create_character(user_id: UserFactory.default_user.id)

      conn = conn() |> put_req_header("content-type", "application/json") |> put("/api/characters/#{character.permalink}", %{strain_current: 5} |> Poison.encode!)

      assert conn.status == 200
      assert conn.resp_body |> Poison.decode! == %{"strain_current" => 5}
    end
  end
end
