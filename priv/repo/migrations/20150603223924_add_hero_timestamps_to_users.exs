defmodule EdgeBuilder.Repo.Migrations.AddHeroTimestampsToUsers do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :bug_reported_at, :utc_datetime
      add :pull_requested_at, :utc_datetime
    end
  end
end
