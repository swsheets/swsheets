defmodule EdgeBuilder.Controllers.VehicleControllerTest do
  use EdgeBuilder.ControllerTest

  alias Factories.UserFactory

  describe "new" do
    it "renders the edit form for a new vehicle" do
      conn = authenticated_request(UserFactory.default_user, :get, "/v/new")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, "New Vehicle")
    end

    it "requires authentication" do
      conn = request(:get, "/v/new")

      assert requires_authentication?(conn)
    end
  end
end
