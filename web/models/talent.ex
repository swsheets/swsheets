defmodule EdgeBuilder.Models.Talent do
  use Ecto.Model

  alias EdgeBuilder.Models.Character

  schema "talents" do
    field :name, :string
    field :book_and_page, :string
    field :description, :string
    belongs_to :character, Character
  end

  def changeset(talent, params \\ %{}) do
    params
      |> cast(talent, ~w(character_id), ~w(name book_and_page description))
  end
end
