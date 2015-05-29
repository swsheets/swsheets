defmodule EdgeBuilder.CharacterView do
  use EdgeBuilder.Web, :view
  import Ecto.Changeset, only: [get_field: 2]

  alias EdgeBuilder.Repo
  alias EdgeBuilder.Models.BaseSkill

  def image_or_default(character) do
    get_field(character, :portrait_url) || "/images/250x250.gif"
  end

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

  def render_text(changeset, field) do
    {:safe, escaped_value} = get_field(changeset, field) |> Phoenix.HTML.html_escape

    {:safe, String.replace(escaped_value, "\n", "<br>")}
  end
end
