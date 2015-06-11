defmodule EdgeBuilder.CharacterView do
  use EdgeBuilder.Web, :view
  import Ecto.Changeset, only: [get_field: 2]

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

  def range_options(selected_range) do
    Enum.map(~w(Engaged Short Medium Long Extreme), fn range ->
      "<option#{if range == selected_range, do: " selected"}>#{range}</option>"
    end) |> raw
  end

  def in_display_order(coll) do
    Enum.sort(coll, &(get_field(&1, :display_order) < get_field(&2, :display_order)))
  end

  def render_text(changeset, field) do
    {:safe, escaped_value} = get_field(changeset, field) |> Phoenix.HTML.html_escape

    {:safe, String.replace(escaped_value, "\n", "<br>")}
  end

  def skill_display_name(skill) do
    "#{skill.name} (#{Characteristic.shorthand_for(skill.characteristic)})"
  end

  def skills_in_system(character_skills, system) do
    Enum.filter(character_skills, fn(cs) ->
      is_nil(cs.system) || cs.system == system
    end)
  end
end
