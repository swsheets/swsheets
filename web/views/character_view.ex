defmodule EdgeBuilder.CharacterView do
  use EdgeBuilder.Web, :view

  alias EdgeBuilder.Repo
  alias EdgeBuilder.Models.BaseSkill
  alias EdgeBuilder.Models.Characteristic
  alias EdgeBuilder.Models.FavoriteList

  def image_or_default(character) do
    get_field(character, :portrait_url) || "/images/250x250.gif"
  end

  def lookup_skill(nil), do: nil
  def lookup_skill(skill_id) do
    Repo.get(BaseSkill, skill_id).name
  end

  def options_for_attack_skills(selected_skill_id) do
    Enum.map(BaseSkill.attack_skills, fn s ->
      selection = if s.id == selected_skill_id, do: "selected"
      system = unless is_nil(s.system), do: "data-system=#{s.system}"

      "<option value='#{s.id}' #{selection} #{system}>#{s.name}</option>"
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

  def user_favorite_lists(conn) do
    if user_id = Plug.Conn.get_session(conn, :current_user_id) do
      FavoriteList.all_by_user_id(user_id)
    end
  end

  def logged_in?(conn) do
    !is_nil(Plug.Conn.get_session(conn, :current_user_id))
  end
end
