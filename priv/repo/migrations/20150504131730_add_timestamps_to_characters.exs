defmodule EdgeBuilder.Repo.Migrations.AddTimestampsToCharacters do
  use Ecto.Migration

  def up do
    alter table(:characters) do
      add :inserted_at, :timestamp
      add :updated_at, :timestamp
    end
  end
end
