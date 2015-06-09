defmodule EdgeBuilder.Repo.Migrations.AddAgeOfRebellion do
  use Ecto.Migration

  def up do
    alter table(:characters) do
      add :system, :string, length: 4
      add :duty, :text
    end

    alter table(:base_skills) do
      add :system, :string, length: 4
    end
  end
end
