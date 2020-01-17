defmodule EdgeBuilder.Repo.Migrations.CreateAnnouncements do
  use Ecto.Migration

  def change do
    create table(:announcements) do
      add(:body, :text)
      add(:level, :string)
      add(:active, :boolean, default: false, null: false)

      timestamps()
    end
  end
end
