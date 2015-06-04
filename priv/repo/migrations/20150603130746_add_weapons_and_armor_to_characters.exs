defmodule EdgeBuilder.Repo.Migrations.AddWeaponsAndArmorToCharacters do
  use Ecto.Migration

  def up do
    alter table(:characters) do
      add :weapons_and_armor, :text
      add :personal_gear, :text
    end

    execute "update characters set personal_gear = gear"
  end
end
