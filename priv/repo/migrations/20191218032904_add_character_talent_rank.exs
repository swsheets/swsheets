defmodule EdgeBuilder.Repo.Migrations.AddCharacterTalentRank do
  use Ecto.Migration

  def change do
    alter table(:talents) do
      add :rank, :integer, default: 1
    end 
  end
end
