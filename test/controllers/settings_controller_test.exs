defmodule EdgeBuilder.Controllers.SettingsControllerTest do
  use EdgeBuilder.ControllerTest

  alias Factories.UserFactory
  alias Helpers.FlokiExt

  describe "edit" do
    it "displays your user information" do
      user = UserFactory.default_user

      conn = authenticated_request(user, :get, "/user/edit")

      assert FlokiExt.find(conn.resp_body, "#email") |> FlokiExt.attribute("value") == user.email
      assert String.contains?(conn.resp_body, user.username)
    end

    it "requires authentication" do
      conn = request(:get, "/user/edit")

      assert is_redirect_to?(conn, "/welcome")
    end
  end
end
