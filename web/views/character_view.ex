defmodule EdgeBuilder.CharacterView do
  use EdgeBuilder.View
  import Ecto.Changeset, only: [get_field: 2]

  alias EdgeBuilder.Repo
  alias EdgeBuilder.Models.BaseSkill

  using do
    quote do
      import EdgeBuilder.Router.Helpers
    end
  end

  def image_or_default(character) do
    get_field(character, :portrait_url) || "/images/250x250.gif"
  end

  def lookup_skill(skill_id) do
    Repo.get(BaseSkill, skill_id).name
  end

  def base_skill_options(skill_id) do
    Enum.map(BaseSkill.attack_skills, fn s ->
      "<option value='#{s.id}'#{if s.id == skill_id, do: " selected"}>#{s.name}</option>"
    end) |> safe
  end

  def range_options(selected_range) do
    Enum.map(~w(Engaged Short Medium Long Extreme), fn range ->
      "<option#{if range == selected_range, do: " selected"}>#{range}</option>"
    end) |> safe
  end
end
