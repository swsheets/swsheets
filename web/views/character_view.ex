defmodule EdgeBuilder.CharacterView do
  use EdgeBuilder.View

  using do
    quote do
      import EdgeBuilder.Router.Helpers
    end
  end

  def image_or_default(character) do
    character.portrait_url || "/images/250x250.gif"
  end
end
