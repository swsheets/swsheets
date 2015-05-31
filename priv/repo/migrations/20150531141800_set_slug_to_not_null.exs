defmodule EdgeBuilder.Repo.Migrations.SetSlugToNotNull do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE characters ALTER COLUMN url_slug SET NOT NULL"
  end
end
