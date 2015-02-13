defmodule EdgeBuilder.Controllers.CharacterControllerTest do
  use EdgeBuilder.ControllerTest

  alias EdgeBuilder.Models.Character

  describe "edit" do
    it "renders the character edit form" do
      character = %Character{
        name: "Greedo",
        species: "Rodian",
        career: "Bounty Hunter"
      } |> EdgeBuilder.Repo.insert

      conn = request(:get, "/characters/#{character.id}/edit")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, "Greedo")
      assert String.contains?(conn.resp_body, "Rodian")
    end
  end
end
