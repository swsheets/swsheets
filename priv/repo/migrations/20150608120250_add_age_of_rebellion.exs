defmodule EdgeBuilder.Repo.Migrations.AddAgeOfRebellion do
  use Ecto.Migration

  def up do
    alter table(:characters) do
      add :system, :string, size: 4
      add :duty, :text
    end

    alter table(:base_skills) do
      add :system, :string, size: 4
    end

    execute "update characters set system = 'eote'"
    execute "update base_skills set system = 'eote'"
  end
end
