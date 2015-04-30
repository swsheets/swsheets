defmodule EdgeBuilder.Models.UserTest do
  use EdgeBuilder.Test

  alias Fixtures.UserFixture
  alias EdgeBuilder.Models.User

  describe "authenticate" do
    it "returns the user when the name and password match" do
      user = UserFixture.create_user(password: "rockabilly", password_confirmation: "rockabilly")

      {:ok, found_user} = User.authenticate(user.username, "rockabilly")
      assert user.id == found_user.id
    end

    it "returns false when the password does not match" do
      user = UserFixture.create_user(password: "rockabilly", password_confirmation: "rockabilly")

      assert {:error, ["No user with that password could be found"]} == User.authenticate(user.username, "classical")
    end
  end
end
