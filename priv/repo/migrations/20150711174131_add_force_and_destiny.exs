defmodule EdgeBuilder.Repo.Migrations.AddForceAndDestiny do
  use Ecto.Migration

  def up do
    create table(:force_powers) do
      add :character_id, :integer
      add :name, :string
      add :description, :string
      add :display_order, :integer

      add :inserted_at, :timestamp
      add :updated_at, :timestamp
    end

    create table(:force_power_upgrades) do
      add :force_power_id, :integer
      add :name, :string
      add :description, :string
      add :display_order, :integer

      add :inserted_at, :timestamp
      add :updated_at, :timestamp
    end

    alter table(:characters) do
      add :morality, :text
      add :force_rating, :integer
    end

    alter table(:base_skills) do
      add :characteristics, {:array, :string}
    end
    
    execute "alter table base_skills alter column characteristic drop not null"

    alter table(:character_skills) do
      add :characteristic, :string
    end
  end
end
