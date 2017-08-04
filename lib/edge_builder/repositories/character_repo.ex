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

  def all_for_user(user_id) do
    Repo.all(
      from c in Character,
      where: c.user_id == ^user_id,
      order_by: [desc: c.inserted_at])
    |> Enum.map(&callbacks/1)
  end

  def recent do
    Repo.all(
      from c in Character,
      order_by: [desc: c.inserted_at],
      limit: 5)
    |> Enum.map(&callbacks/1)
  end

  def full_character(permalink) do
    url_slug = String.replace(permalink, ~r/-.*/, "")

    Repo.one!(
      from c in Character,
        where: c.url_slug == ^url_slug,
        preload: [:talents, :attacks, :character_skills],
        preload: [force_powers: :force_power_upgrades]
    ) |> callbacks()
  end

  defp callbacks(character) do
    Character.set_permalink(character)
  end

  defp callbacks_paginated(paged_characters) do
    Map.put(paged_characters, :entries, Enum.map(paged_characters.entries, &callbacks/1))
  end
end
