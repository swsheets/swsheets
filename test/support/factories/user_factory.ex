defmodule Factories.UserFactory do
  use Factories.BaseFactory

  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Repo
  import Ecto.Query, only: [from: 2]

  @default_password "jediknight"

  @defaults %{
    username: "bobafett",
    email: "fett@example.com",
    crypted_password: User.crypt_password(@default_password),
    favorite_lists: []
  }

  def create_user(overrides \\ []) do
    if is_nil(overrides[:username]) do
      overrides = Keyword.put(overrides, :username, @defaults[:username] <> Integer.to_string(next_counter))
    end
    if !is_nil(overrides[:password]) do
      overrides = Keyword.put(overrides, :crypted_password, User.crypt_password(overrides[:password]))
    end
    params = Enum.into(overrides, @defaults)
    %User{} |> Map.merge(params) |> Repo.insert!
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
    case Repo.one(from u in User, where: u.username == ^@default_username, preload: [:favorite_lists]) do
      nil -> create_user(username: @default_username)
      u -> u
    end
  end
end
