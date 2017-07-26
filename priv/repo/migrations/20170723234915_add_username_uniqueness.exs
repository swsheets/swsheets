defmodule EdgeBuilder.Repo.Migrations.AddUsernameUniqueness do
  use Ecto.Migration

  def up do
    create unique_index(:users, ["upper(username)"])
  end
end
