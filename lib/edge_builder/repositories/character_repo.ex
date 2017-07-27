defmodule EdgeBuilder.Repositories.CharacterRepo do
  alias EdgeBuilder.Repo
  alias EdgeBuilder.Models.Character
  import Ecto.Query, only: [from: 2]

  def all(page \\ 0) do
    Repo.paginate(
      (from c in Character,
      order_by: [desc: c.inserted_at]),
      page: page)
    |> callbacks_paginated()
  end

  defp callbacks(character) do
    EdgeBuilder.Models.Character.set_permalink(character)
  end

  defp callbacks_paginated(paged_characters) do
    Map.put(paged_characters, :entries, Enum.map(paged_characters.entries, &(callbacks(&1))))
  end
end
