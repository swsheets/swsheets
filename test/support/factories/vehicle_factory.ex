defmodule Factories.VehicleFactory do
  use Factories.BaseFactory

  alias Factories.UserFactory
  alias EdgeBuilder.Models.Vehicle
  alias EdgeBuilder.Repo

  @defaults %{
    name: "Triumphant Failure"
  }

  def create_vehicle(overrides \\ []) do
    overrides = if is_nil(overrides[:name]) do
      Keyword.put(overrides, :name, @defaults[:name] <> Integer.to_string(next_counter()))
    else
      overrides
    end
    params = Enum.into(overrides, @defaults)
    user_id = params[:user_id] || UserFactory.default_user.id

    Vehicle.changeset(%Vehicle{}, user_id, parameterize(params)) |> Repo.insert! |> Vehicle.set_permalink
  end

  def default_parameters do
    @defaults |> parameterize
  end
end
