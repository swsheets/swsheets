Code.require_file("user_factory.exs", __DIR__)

defmodule Factories.VehicleFactory do
  use FactoryGirlElixir.Factory

  alias Factories.UserFactory
  alias EdgeBuilder.Models.Vehicle
  alias EdgeBuilder.Repo

  factory :vehicle do
    field :name, &("Triumphant Failure #{&1}")
  end

  def create_vehicle(overrides \\ []) do
    params = attributes_for(:vehicle, overrides) |> parametrize
    user_id = params["user_id"] || UserFactory.default_user.id

    Vehicle.changeset(%Vehicle{}, user_id, params) |> Repo.insert
  end

  def default_parameters do
    attributes_for(:vehicle) |> parametrize
  end
end
