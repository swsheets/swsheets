defmodule EdgeBuilder.Repo.Migrations.UpdatePortraitUrlType do
  use Ecto.Migration

  def up do
    alter table(:characters) do
      modify(:portrait_url, :string, size: 2048)
    end

    alter table(:vehicles) do
      modify(:portrait_url, :string, size: 2048)
    end
  end

  def down do
    alter table(:characters) do
      modify(:portrait_url, :string)
    end

    alter table(:vehicles) do
      modify(:portrait_url, :string)
    end
  end
end
