defmodule EdgeBuilder.CharacterView do
  use EdgeBuilder.View
  import Ecto.Changeset, only: [get_field: 2]

  using do
    quote do
      import EdgeBuilder.Router.Helpers
    end
  end

  def image_or_default(character) do
    get_field(character, :portrait_url) || "/images/250x250.gif"
  end
end
