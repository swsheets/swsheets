defmodule EdgeBuilder.Controllers.ProfileControllerTest do
  use EdgeBuilder.ControllerTest

  alias Factories.UserFactory
  describe "show" do
    it "shows the username" do
      user = UserFactory.create_user

      conn = request(:get, "/p/#{user.username}")

      assert String.contains?(conn.resp_body, user.username)
    end
  end
end
