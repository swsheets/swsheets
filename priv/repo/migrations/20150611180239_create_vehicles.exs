defmodule EdgeBuilder.Repo.Migrations.CreateVehicles do
  use Ecto.Migration

  def up do
    create table(:vehicles) do
      add :name, :string, null: false
      add :make, :string
      add :hard_points, :integer
      add :encumbrance, :string
      add :silhouette, :integer
      add :speed, :integer
      add :handling, :integer
      add :current_speed, :integer
      add :armor, :integer
      add :hull_threshold, :integer
      add :hull_current, :integer
      add :strain_threshold, :integer
      add :strain_current, :integer
      add :defense_fore, :integer
      add :defense_fore_current, :integer
      add :defense_aft, :integer
      add :defense_aft_current, :integer
      add :defense_port, :integer
      add :defense_port_current, :integer
      add :defense_starboard, :integer
      add :defense_starboard_current, :integer
      add :sensor_range, :string
      add :cargo, :text
      add :notes, :text
      add :special_features, :text
      add :hyperdrive, :string
      add :crew, :string
      add :passengers, :string
      add :consumables, :string
      add :faction, :string
      add :portrait_url, :string
      add :price, :string
      add :rarity, :string
      add :type, :string
      add :user_id, :integer
      add :inserted_at, :timestamp
      add :updated_at, :timestamp
    end

    execute "
      CREATE FUNCTION new_vehicle_url_slug() RETURNS text AS $$
      DECLARE
        new_slug text;
        done bool;
      BEGIN
        done := false;
        WHILE NOT done LOOP
          new_slug := lower(substring(regexp_replace(encode(gen_random_bytes(32), 'base64'), '[^a-zA-Z0-9]+', '', 'g'), 0, 10));
          done := NOT exists(SELECT 1 FROM vehicles WHERE url_slug = new_slug);
        END LOOP;
        RETURN new_slug;
      END;
      $$ LANGUAGE PLPGSQL VOLATILE;
    "

    execute "ALTER TABLE vehicles ADD COLUMN url_slug varchar(10) DEFAULT new_vehicle_url_slug()"

    create table(:vehicle_attacks) do
      add :vehicle_id, :integer, null: false
      add :weapon_name, :string
      add :firing_arc, :string
      add :damage, :string
      add :range, :string
      add :critical, :string
      add :specials, :string
      add :display_order, :integer
    end

    create table(:vehicle_attachments) do
      add :vehicle_id, :integer, null: false
      add :name, :string
      add :hard_points_required, :integer, default: 0
      add :base_modifiers, :string
      add :modifications, :string
      add :display_order, :integer, default: 0
    end
  end
end
