defmodule EdgeBuilder.Repo.Migrations.ConvertFieldsToText do
  use Ecto.Migration

  def up do
    alter table(:vehicle_attachments) do
      modify :base_modifiers, :text
      modify :modifications, :text
    end

    alter table(:talents) do
      modify :description, :text
    end
  end
end
