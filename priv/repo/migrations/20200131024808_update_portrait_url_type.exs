defmodule EdgeBuilder.Repo.Migrations.UpdatePortraitUrlType do
  use Ecto.Migration

  def change do
    alter table(:characters) do
      modify(:portrait_url, :text)
    end

    alter table(:vehicles) do
      modify(:portrait_url, :text)
    end
  end
end
