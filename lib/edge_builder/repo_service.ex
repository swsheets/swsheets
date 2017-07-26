defmodule EdgeBuilder.RepoService do
  alias EdgeBuilder.Repo
  import Ecto.Query, only: [from: 2]

  def all_paginated(schema, page) do
    Repo.paginate((from s in schema, order_by: [desc: s.inserted_at]), page: page) |> parameterize_all()
  end

  def upsert(changeset) do
    result = if is_nil(Ecto.Changeset.get_field(changeset, :id)) do
      Repo.insert!(changeset)
    else
      Repo.update!(changeset)
    end
 
    parameterize(result)
  end

  defp parameterize(character = %EdgeBuilder.Models.Character{}) do
    EdgeBuilder.Models.Character.set_permalink(character)
  end
  defp parameterize(vehicle = %EdgeBuilder.Models.Vehicle{}) do
    EdgeBuilder.Models.Vehicle.set_permalink(vehicle)
  end
  defp parameterize(default), do: default

  defp parameterize_all(page) do
    Map.put(page, :entries, Enum.map(page.entries, &(parameterize(&1))))
  end
end
