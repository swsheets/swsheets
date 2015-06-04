defmodule EdgeBuilder.Repo.Migrations.AddHeroTimestampsToUsers do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :bug_reported_at, :datetime
      add :pull_requested_at, :datetime
    end
  end
end
