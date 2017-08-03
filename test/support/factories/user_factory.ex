defmodule Factories.UserFactory do
  use Factories.BaseFactory

  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Repo
  import Ecto.Query, only: [from: 2]

  @defaults %{
    username: "bobafett",
    email: "fett@example.com",
    password: "jediknight",
    password_confirmation: "jediknight"
  }

  # this method should not return a pair, it should simply fail if it can't create the user.
  # that would also mean removing its sibling, create_user!/1 below.
  # however, there is one annoying test that requires this version to test user errors.
  # so until then, it remains.
  def create_user(overrides \\ []) do
    overrides = if is_nil(overrides[:username]) do
      Keyword.put(overrides, :username, @defaults[:username] <> Integer.to_string(next_counter()))
    else
      overrides
    end

    overrides = if is_nil(overrides[:email]) do
      Keyword.put(overrides, :email, @defaults[:email] <> Integer.to_string(next_counter()))
    else
      overrides
    end

    overrides = if !is_nil(overrides[:password]) do
      Keyword.put(overrides, :crypted_password, User.crypt_password(overrides[:password]))
    else
      overrides
    end
    params = Enum.into(overrides, @defaults)
    User.changeset(%User{}, :create, params) |> Repo.insert
  end

  def create_user!(overrides \\ []) do
    {:ok, user} = create_user(overrides)
    user
  end

  @token Ecto.UUID.generate
  def add_password_reset_token(user) do
    User.changeset(user, :password_reset, %{password_reset_token: @token}) |> Repo.update!
  end


  def set_contributions(user, overrides) do
    User.changeset(user, :contributions, Enum.into(overrides, %{})) |> Repo.update!
  end

  @default_username "phil"
  def default_user do
    case Repo.one(from u in User, where: u.username == ^@default_username) do
      nil -> create_user!(username: @default_username)
      u -> u
    end
  end
end
