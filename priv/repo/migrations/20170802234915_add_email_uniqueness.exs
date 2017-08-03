defmodule EdgeBuilder.Repo.Migrations.AddEmailUniqueness do
  use Ecto.Migration

  def up do
    create unique_index(:users, ["upper(email)"])
  end
end
