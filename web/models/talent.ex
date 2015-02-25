defmodule EdgeBuilder.Models.Talent do
  use EdgeBuilder.Model

  alias EdgeBuilder.Models.Character

  schema "talents" do
    field :name, :string
    field :book_and_page, :string
    field :description, :string
    belongs_to :character, Character
  end

  def changeset(talent, params \\ %{}) do
    params
      |> cast(talent, [], ~w(character_id name book_and_page description))
  end

  def is_default_changeset?(changeset) do
    default = struct(__MODULE__)

    Enum.all?([:name, :book_and_page, :description], fn field ->
      Ecto.Changeset.get_field(changeset, field) == Map.fetch!(default, field)
    end)
  end

  def for_character(character_id) do
    Repo.all(
      from t in __MODULE__,
        where: t.character_id == ^character_id
    )
  end
end
