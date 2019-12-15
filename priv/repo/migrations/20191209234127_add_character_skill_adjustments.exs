defmodule EdgeBuilder.Repo.Migrations.AddCharacterSkillAdjustments do
  use Ecto.Migration

  def change do
    alter table(:character_skills) do
      add :adjustments, :text
    end

  end
end
