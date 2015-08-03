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

  def by_skill_group(skills) do
    skills
    |> Enum.group_by(&(&1.skill_group))
    |> Enum.map(fn {group, skills} -> {group, Enum.sort_by(skills, &(&1.display_order))} end)
    |> Enum.sort_by(fn {_, skills} -> Enum.min_by(skills, &(&1.display_order)) end)
  end

  def is_skill_displayed?(skill, skills)
  def is_skill_displayed?(skill, [skill]), do: true                   # Always display the only member of a skill group
  def is_skill_displayed?(%{is_selected_in_group: true}, _), do: true # Always display a skill that is selected
  def is_skill_displayed?(skill, skills) do                         # Otherwise, only display a skill if it is the first in its group
    if Enum.any?(skills, &(&1.is_selected_in_group)) do
      false
    else
      skill == Enum.at(skills, 0)
    end
  end

  def is_skill_toggle_displayed?([_]), do: false
  def is_skill_toggle_displayed?(_), do: true
end
