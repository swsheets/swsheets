defmodule Fixtures.UserFixture do
  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Repo
  import Ecto.Query, only: [from: 2]

  @defaults %{
    username: "phil",
    email: "phil@example.com",
    password: "jediknight",
    password_confirmation: "jediknight"
  }

  def default_user do
    case Repo.one(from u in User, where: u.username == ^@defaults.username) do
      nil -> create_user
      u -> u
    end
  end

  def create_user(overrides \\ %{})
  def create_user(overrides) when is_list(overrides), do: create_user(Enum.into(overrides, %{}))
  def create_user(overrides) when is_map(overrides) do
    params = Map.merge(@defaults, overrides)

    User.changeset(%User{}, params) |> Repo.insert
  end
end
