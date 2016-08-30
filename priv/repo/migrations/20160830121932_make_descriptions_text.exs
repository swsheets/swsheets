defmodule EdgeBuilder.Repo.Migrations.MakeDescriptionsText do
  use Ecto.Migration

  def up do
    execute "alter table force_powers alter column description type text"
    execute "alter table force_power_upgrades alter column description type text"
  end
end
