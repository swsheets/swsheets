defmodule EdgeBuilder.Repo.Migrations.CreateFavoriteLists do
  use Ecto.Migration

  def change do
    create table(:favorite_lists) do
      add :name, :string, null: false
      add :user_id, references(:users)
      timestamps
    end

    create table(:favoritings) do
      add :favorite_list_id, references(:favorite_lists)
      add :character_id, references(:characters)
      add :vehicle_id, references(:vehicles)
      timestamps
    end
  end
end
