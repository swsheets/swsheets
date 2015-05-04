Code.require_file("user_factory.exs", __DIR__)

defmodule Factories.CharacterFactory do
  use FactoryGirlElixir.Factory

  alias Factories.UserFactory
  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Repo

  factory :character do
    field :name, &("ZappoGrappo#{&1}")
    field :species, "Fuzz"
    field :career, "Stock Broker"
  end

  def create_character(overrides \\ []) do
    params = attributes_for(:character, overrides) |> parametrize
    user_id = params["user_id"] || UserFactory.default_user.id

    Character.changeset(%Character{}, user_id, params) |> Repo.insert
  end

  def default_parameters do
    attributes_for(:character) |> parametrize
  end
end
