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

  def create_user(overrides \\ []) do
    if is_nil(overrides[:username]) do
      overrides = Keyword.put(overrides, :username, @defaults[:username] <> Integer.to_string(next_counter))
    end
    params = Enum.into(overrides, @defaults)
    User.changeset(%User{}, :create, params) |> Repo.insert
  end

  def add_password_reset_token(user) do
    User.changeset(user, :password_reset, %{password_reset_token: Ecto.UUID.generate}) |> Repo.update
  end

  def set_contributions(user, overrides) do
    User.changeset(user, :contributions, Enum.into(overrides, %{})) |> Repo.update
  end

  @default_username "phil"
  def default_user do
    case Repo.one(from u in User, where: u.username == ^@default_username) do
      nil -> create_user(username: @default_username)
      u -> u
    end
  end
end
