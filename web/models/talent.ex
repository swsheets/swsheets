defmodule EdgeBuilder.Models.Talent do
  use Ecto.Model

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Repo
  import Ecto.Query, only: [from: 2]

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

  def for_character(character_id) do
    Repo.all(
      from t in __MODULE__,
        where: t.character_id == ^character_id
    )
  end
end
