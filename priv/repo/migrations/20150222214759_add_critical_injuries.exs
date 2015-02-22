defmodule EdgeBuilder.Repo.Migrations.AddCriticalInjuries do
  use Ecto.Migration

  def up do
    alter table(:characters) do
      add :critical_injuries, :text
    end
  end

  def down do
    alter table(:characters) do
      remove :critical_injuries
    end
  end
end
