defmodule EdgeBuilder.Repo.Migrations.CreateCharacters do
  use Ecto.Migration

  def up do
    create table(:characters) do
      add :name, :string, null: false
      add :species, :string, null: false
      add :career, :string, null: false
      add :specializations, :string
      add :portrait_url, :string
      add :soak, :integer
      add :wounds_threshold, :integer
      add :wounds_current, :integer
      add :strain_threshold, :integer
      add :strain_current, :integer
      add :defense_ranged, :integer
      add :defense_melee, :integer
      add :characteristic_brawn, :integer
      add :characteristic_agility, :integer
      add :characteristic_intellect, :integer
      add :characteristic_cunning, :integer
      add :characteristic_willpower, :integer
      add :characteristic_presence, :integer
      add :gear, :text
      add :credits, :integer
      add :encumbrance, :string
      add :xp_available, :integer
      add :xp_total, :integer
      add :background, :text
      add :motivation, :text
      add :obligation, :text
      add :obligation_amount, :string
      add :description, :text
      add :other_notes, :text
    end

    create table(:skills) do
      add :name, :string, null: false
      add :characteristic, :string, null: false
      add :is_attack_skill, :bool, default: false
      add :attack_skill_position, :integer
    end

    create table(:characters_skills) do
      add :character_id, :integer, null: false
      add :skill_id, :integer, null: false
      add :is_career, :boolean, null: false, default: false
      add :rank, :integer, null: false, default: 0
    end

    create table(:attacks) do
      add :character_id, :integer, null: false
      add :weapon_name, :string
      add :range, :string
      add :skill_id, :integer
      add :specials, :string
      add :damage, :string
      add :critical, :string
    end

    create table(:talents) do
      add :character_id, :integer, null: false
      add :name, :string
      add :book_and_page, :string
      add :description, :string
    end
  end

  def down do
    Enum.each [:characters, :skills, :characters_skills, :attacks, :talents], fn(table_name) ->
      drop table(table_name)
    end
  end
end
