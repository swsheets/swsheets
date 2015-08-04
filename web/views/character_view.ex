defmodule EdgeBuilder.CharacterView do
  use EdgeBuilder.Web, :view

  alias EdgeBuilder.Repo
  alias EdgeBuilder.Models.BaseSkill
  alias EdgeBuilder.Models.Characteristic

  def image_or_default(character) do
    get_field(character, :portrait_url) || "/images/250x250.gif"
  end

  def lookup_skill(nil), do: nil
  def lookup_skill(skill_id) do
    Repo.get(BaseSkill, skill_id).name
  end

  def base_skill_options(skill_id) do
    Enum.map(BaseSkill.attack_skills, fn s ->
      "<option value='#{s.id}'#{if s.id == skill_id, do: " selected"}>#{s.name}</option>"
    end) |> raw
  end

  def skill_display_name(skill) do
    "#{skill.name} (#{Characteristic.shorthand_for(skill.characteristic)})"
  end

  def skills_in_system(character_skills, system) do
    Enum.filter(character_skills, fn(cs) ->
      is_nil(cs.system) || cs.system == system
    end)
  end

  def selected_characteristic(skill) do
    if Enum.member?(skill.characteristics, skill.characteristic) do
      skill.characteristic
    else
      Enum.at(skill.characteristics, 0)
    end
  end

  def is_characteristic_toggle_displayed?([_]), do: false
  def is_characteristic_toggle_displayed?(_), do: true
end
