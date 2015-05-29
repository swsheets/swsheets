defmodule EdgeBuilder.Repo.Migrations.DropSkillPosition do
  use Ecto.Migration

  def up do
    alter table(:base_skills) do
      remove :skill_position
    end
  end
end
