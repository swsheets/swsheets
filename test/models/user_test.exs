defmodule EdgeBuilder.Models.UserTest do
  use EdgeBuilder.ModelCase

  alias Factories.UserFactory
  alias EdgeBuilder.Models.User

  describe "authenticate" do
    it "returns the user when the name and password match" do
      user = UserFactory.create_user!(password: "rockabilly", password_confirmation: "rockabilly")

      {:ok, found_user} = User.authenticate(user.username, "rockabilly")
      assert user.id == found_user.id
    end

    it "returns false when the password does not match" do
      user = UserFactory.create_user!(password: "rockabilly", password_confirmation: "rockabilly")

      assert {:error, ["No user with that password could be found"]} == User.authenticate(user.username, "classical")
    end
  end

  describe "changeset" do
    it "generates an error when the username is taken" do
      UserFactory.create_user!(username: "bobafett")

      {:error, changeset} = UserFactory.create_user(username: "bobafett")
      assert has_error?(changeset, :username, "has already been taken")

      {:ok, _} = UserFactory.create_user(username: "gonzothegreat")
    end

    it "generates an error when the email is taken" do
      UserFactory.create_user!(email: "boba@fett.com")

      {:error, changeset} = UserFactory.create_user(email: "boba@fett.com")
      assert has_error?(changeset, :email, "has already been taken")

      {:ok, _} = UserFactory.create_user(email: "gonzo@thegreat.net")
    end

    it "generates an error when the password and confirmation do not match" do
      changeset = User.changeset(%User{}, :create, %{"password" => "hot dogs", "password_confirmation" => "cream cheese"})
      assert has_error?(changeset, :password, "does not match the confirmation")

      changeset = User.changeset(%User{}, :create, %{"password" => "cream cheese", "password_confirmation" => "cream cheese"})
      assert !has_error?(changeset, :password, "does not match the confirmation")
    end

    it "generates an error when the password is not long enough" do
      changeset = User.changeset(%User{}, :create, %{"password" => "hot dogs"})
      assert has_error?(changeset, :password, "must be at least 10 characters")

      changeset = User.changeset(%User{}, :create, %{"password" => "1234567890"})
      assert !has_error?(changeset, :password, "must be at least 10 characters")
    end

    it "generates an error when the email address is not a valid email" do
      changeset = User.changeset(%User{}, :create, %{"email" => "bobatexample.com"})
      assert has_error?(changeset, :email, "must be a valid email address")

      changeset = User.changeset(%User{}, :create, %{"email" => "bob@example.com"})
      assert !has_error?(changeset, :email, "must be a valid email address")
    end

    it "generates an error when the username contains characters other than a-zA-Z0-9" do
      changeset = User.changeset(%User{}, :create, %{"username" => "Asmo Diel"})
      assert has_error?(changeset, :username, "must contain only letters and numbers")

      changeset = User.changeset(%User{}, :create, %{"username" => "Asmo0Diel"})
      assert !has_error?(changeset, :username, "must contain only letters and numbers")
    end

    it "generates an error when the username is too long" do
      changeset = User.changeset(%User{}, :create, %{"username" => "1234567890123456789012345678901"})
      assert has_error?(changeset, :username, "must contain no more than 30 characters")

      changeset = User.changeset(%User{}, :create, %{"username" => "123456789012345678901234567890"})
      assert !has_error?(changeset, :username, "must contain no more than 30 characters")
    end
  end
end
