defmodule EdgeBuilder.Repo.Migrations.AddAssetsAndResources do
  use Ecto.Migration

  def up do
    alter table(:characters) do
      add :assets_and_resources, :text
    end
  end
end
