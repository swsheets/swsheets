defmodule EdgeBuilder.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    create table(:users) do
      add :username, :string, null: false
      add :email, :string, null: false
      add :crypted_password, :binary, null: false
    end
  end
end
