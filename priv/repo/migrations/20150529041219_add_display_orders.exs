defmodule EdgeBuilder.Repo.Migrations.AddDisplayOrderToTalentsAndAttacks do
  use Ecto.Migration

  def up do
    alter table(:talents) do
      add :display_order, :integer
    end

    alter table(:attacks) do
      add :display_order, :integer
    end

    alter table(:base_skills) do
      add :display_order, :integer
    end

    execute "UPDATE base_skills SET display_order = skill_position"
  end
end
