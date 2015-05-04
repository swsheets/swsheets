defmodule EdgeBuilder.Repo.Migrations.AddUserToCharacters do
  use Ecto.Migration

  def up do
    alter table(:characters) do
      add :user_id, :integer
    end
  end
end
