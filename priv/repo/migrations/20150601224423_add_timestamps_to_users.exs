defmodule EdgeBuilder.Repo.Migrations.AddTimestampsToUsers do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :inserted_at, :timestamp
      add :updated_at, :timestamp
    end

    execute "update users set inserted_at = now(), updated_at = now()"
  end
end
