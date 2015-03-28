defmodule EdgeBuilder.Controllers.PageControllerTest do
  use EdgeBuilder.ControllerTest

  describe "index" do
    it "renders the character edit form for a new character" do
      conn = request(:get, "/")

      assert is_redirect_to?(conn, EdgeBuilder.Router.Helpers.character_path(conn, :index))
    end
  end
end
