defmodule Factories.CharacterFactory do
  use Factories.BaseFactory

  alias Factories.UserFactory
  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Repo

  @defaults %{
    name: "ZappoGrappo",
    species: "Fuzz",
    career: "Stock Broker",
    system: :eote
  }

  def create_character(overrides \\ []) do
    if is_nil(overrides[:name]) do
      overrides = Keyword.put(overrides, :name, @defaults[:name] <> Integer.to_string(next_counter))
    end
    params = Enum.into(overrides, @defaults)
    user_id = params[:user_id] || UserFactory.default_user.id

    Character.changeset(%Character{}, user_id, parameterize(params)) |> Repo.insert
  end

  def default_parameters do
    @defaults |> parameterize
  end
end
