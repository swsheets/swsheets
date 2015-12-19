defmodule EdgeBuilder.Models.Favoriting do
  use EdgeBuilder.Web, :model

  alias EdgeBuilder.Models.FavoriteList
  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.Vehicle

  schema "favoritings" do
    belongs_to :favorite_list, FavoriteList
    belongs_to :character, Character
    belongs_to :vehicle, Vehicle
    timestamps
  end
end
