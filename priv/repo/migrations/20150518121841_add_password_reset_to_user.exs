defmodule EdgeBuilder.Repo.Migrations.AddPasswordResetToUser do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :password_reset_token, :uuid
    end
  end
end
