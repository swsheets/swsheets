defmodule Factories.UserFactory do
  use FactoryGirlElixir.Factory

  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Repo
  import Ecto.Query, only: [from: 2]

  factory :user do
    field :username, &("bobafett#{&1}")
    field :email, "fett@example.com"
    field :password, "jediknight"
    field :password_confirmation, "jediknight"
  end

  def create_user(overrides \\ []) do
    params = attributes_for(:user, overrides) |> parametrize
    User.changeset(%User{}, :create, params) |> Repo.insert
  end

  def add_password_reset_token(user) do
    User.changeset(user, :password_reset, %{password_reset_token: Ecto.UUID.generate}) |> Repo.update
  end

  @default_username "phil"
  def default_user do
    case Repo.one(from u in User, where: u.username == ^@default_username) do
      nil -> create_user(username: @default_username)
      u -> u
    end
  end
end
