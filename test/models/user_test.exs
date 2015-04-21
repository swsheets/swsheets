defmodule EdgeBuilder.Models.UserTest do
  use EdgeBuilder.Test

  alias Fixtures.UserFixture
  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Repo

  describe "password_matches?" do
    it "returns true when the password matches" do
      user = UserFixture.create_user(password: "rockabilly", password_confirmation: "rockabilly")

      assert User.password_matches?(user, "rockabilly")
    end

    it "returns false when the password does not match" do
      user = UserFixture.create_user(password: "rockabilly", password_confirmation: "rockabilly")

      assert !User.password_matches?(user, "classical")
    end
  end
end
