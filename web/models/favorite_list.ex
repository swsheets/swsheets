defmodule EdgeBuilder.Models.FavoriteList do
  use EdgeBuilder.Web, :model

  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Models.Favoriting
  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.Vehicle

  schema "favorite_lists" do
    field :name, :string

    belongs_to :user, User
    has_many :character_favoritings, Favoriting, foreign_key: :favorite_list_id, on_delete: :delete_all
    has_many :characters, through: [:character_favoritings, :character]
    has_many :vehicle_favoritings, Favoriting, foreign_key: :favorite_list_id, on_delete: :delete_all
    has_many :vehicles, through: [:vehicle_favoritings, :vehicle]
    timestamps
  end

  def add_character(list, character) do
    favoriting = %Favoriting{character_id: character.id, favorite_list_id: list.id}
    Repo.insert! favoriting
    %__MODULE__{list | characters: [character | list.characters]}
  end

  def add_vehicle(list, vehicle) do
    favoriting = Ecto.Model.build(list, :vehicle_favoritings, vehicle_id: vehicle.id)
    Repo.insert! favoriting
    %__MODULE__{list | vehicles: [vehicle | list.vehicles]}
  end
end
