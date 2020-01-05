defmodule EdgeBuilder.Repo.Migrations.AddCharacterPrivateNotes do
  use Ecto.Migration

  def change do
    alter table(:characters) do
      add :private_notes, :text
    end

    alter table(:vehicles) do
      add :private_notes, :text
    end
  end
end
