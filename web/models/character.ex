defmodule EdgeBuilder.Models.Character do
  use EdgeBuilder.Web, :model

  alias EdgeBuilder.Models.Talent
  alias EdgeBuilder.Models.Attack
  alias EdgeBuilder.Models.CharacterSkill
  alias EdgeBuilder.Models.ForcePower
  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Models.Helpers.ModelHelper

  @derive {Phoenix.Param, key: :permalink}
  schema "characters" do
    field :url_slug, :string, read_after_writes: true
    field :permalink, :string, virtual: true
    field :name, :string
    field :species, :string
    field :career, :string
    field :specializations, :string
    field :portrait_url, :string
    field :soak, :integer, default: 0
    field :wounds_threshold, :integer, default: 0
    field :wounds_current, :integer, default: 0
    field :strain_threshold, :integer, default: 0
    field :strain_current, :integer, default: 0
    field :defense_ranged, :integer, default: 0
    field :defense_melee, :integer, default: 0
    field :characteristic_brawn, :integer, default: 1
    field :characteristic_agility, :integer, default: 1
    field :characteristic_intellect, :integer, default: 1
    field :characteristic_cunning, :integer, default: 1
    field :characteristic_willpower, :integer, default: 1
    field :characteristic_presence, :integer, default: 1
    field :weapons_and_armor, :string
    field :personal_gear, :string
    field :assets_and_resources, :string
    field :credits, :integer
    field :encumbrance, :string
    field :xp_available, :integer
    field :xp_total, :integer
    field :background, :string
    field :motivation, :string
    field :obligation, :string
    field :duty, :string
    field :morality, :string
    field :description, :string
    field :other_notes, :string
    field :critical_injuries, :string
    field :force_rating, :integer
    field :private_notes, :string

    field :system, Ecto.Enum, values: [:eote, :aor, :fad]

    timestamps()
    belongs_to :user, User

    has_many :talents, Talent
    has_many :attacks, Attack
    has_many :character_skills, CharacterSkill
    has_many :force_powers, ForcePower
  end

  defp required_fields, do: [:name, :species, :career, :user_id, :system]
  defp allowed_fields, do: __schema__(:fields) -- [:id, :url_slug]
  defp string_fields, do: [:name, :species, :career, :specializations, :encumbrance]

  def changeset(character, user_id, params \\ %{}) do
    character
    |> cast(Map.put(clean_params(params), "user_id", user_id), allowed_fields())
    |> validate_required(required_fields())
    |> validate_format(:portrait_url, ~r/^https:\/\/.*/, message: "must begin with \"https://\"")
    |> ModelHelper.validate_length_many(string_fields(), 255)
    |> validate_length(:portrait_url, max: 2048)
    |> Ecto.Changeset.delete_change(:url_slug)
  end

  def delete(character) do
    Enum.each([Talent, Attack, CharacterSkill], fn child_module ->
      Repo.delete_all(from c in child_module, where: c.character_id == ^character.id)
    end)

    Repo.delete!(character)
  end

  def set_permalink(character) do
    Map.put(character, :permalink, "#{character.url_slug}-#{urlify(character.name)}")
  end

  defp urlify(name) do
    String.replace(name, ~r/\W/, "-")
    |> String.slice(0, 15)
    |> String.downcase()
  end

  defp clean_params(params) do
    params |> clean_portrait_url()
  end

  defp clean_portrait_url(params) do
    if params["portrait_url"] do
      Map.put(params, "portrait_url", fix_imgur_url(params["portrait_url"]))
    else
      params
    end
  end

  defp fix_imgur_url(url) when is_bitstring(url) do
    regex = ~r/^https:\/\/imgur\.com\/gallery\/([^\/]+)/

    case Regex.run(regex, url) do
      [_full, permalink] -> "https://i.imgur.com/#{permalink}.jpg"
      nil -> url
    end
  end

  defp fix_imgur_url(non_string_value), do: non_string_value
end
