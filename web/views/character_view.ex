defmodule EdgeBuilder.CharacterView do
  use EdgeBuilder.View

  def image_or_default(character) do
    character.portrait_url || "/images/250x250.gif"
  end
end
