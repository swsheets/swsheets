defmodule EdgeBuilder.Repo.Migrations.AddDisplayOrderToTalentsAndAttacks do
  use Ecto.Migration

  def up do
    alter table(:talents) do
      add :display_order, :integer
    end

    alter table(:attacks) do
      add :display_order, :integer
    end
  end
end
