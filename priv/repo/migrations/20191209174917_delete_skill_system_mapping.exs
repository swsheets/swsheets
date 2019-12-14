defmodule EdgeBuilder.Repo.Migrations.DeleteSkillSystemMapping do
  use Ecto.Migration

  def change do
    alter table(:base_skills) do
      remove(:system)
    end
  end
end
