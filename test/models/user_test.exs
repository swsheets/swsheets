defmodule EdgeBuilder.Models.UserTest do
  use EdgeBuilder.Test

  alias Factories.UserFactory
  alias EdgeBuilder.Models.User

  describe "authenticate" do
    it "returns the user when the name and password match" do
      user = UserFactory.create_user(password: "rockabilly", password_confirmation: "rockabilly")

      {:ok, found_user} = User.authenticate(user.username, "rockabilly")
      assert user.id == found_user.id
    end

    it "returns false when the password does not match" do
      user = UserFactory.create_user(password: "rockabilly", password_confirmation: "rockabilly")

      assert {:error, ["No user with that password could be found"]} == User.authenticate(user.username, "classical")
    end
  end

  describe "changeset" do
    it "generates an error when the username is taken" do
      UserFactory.create_user(username: "bobafett")

      changeset = User.changeset(%User{}, :create, %{"username" => "bobafett"})
      assert has_error?(changeset, :username, "has already been taken")
    end

    it "generates an error when the password and confirmation do not match" do
      changeset = User.changeset(%User{}, :create, %{"password" => "hot dogs", "password_confirmation" => "cream cheese"})
      assert has_error?(changeset, :password, "does not match the confirmation")
    end

    it "generates an error when the password is not long enough" do
      changeset = User.changeset(%User{}, :create, %{"password" => "hot dogs"})
      assert has_error?(changeset, :password, "must be at least 10 characters")
    end

    it "generates an error when the email address is not a valid email" do
      changeset = User.changeset(%User{}, :create, %{"email" => "bobatbob.com"})
      assert has_error?(changeset, :email, "must be a valid email address")
    end
  end
end
