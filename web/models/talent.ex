defmodule EdgeBuilder.Models.Talent do
  use Ecto.Model

  alias EdgeBuilder.Models.Character

  schema "talents" do
    field :name, :string
    field :book_and_page, :string
    field :description, :string
    belongs_to :character, Character
  end
end
