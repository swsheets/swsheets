defmodule EdgeBuilder.Changemap do
  import Ecto.Query, only: [from: 2]

  def valid?(changemap) do
    changemap
      |> Map.values
      |> List.flatten
      |> Enum.all?(&(&1.valid?))
  end

  def delete_missing(changemap = %{root: root}) do
    root_model = root.__struct__

    associations = Map.delete(changemap, :root)

    Enum.each(associations, fn {field, models} ->
      association = root_model.__schema__(:association, field)

      EdgeBuilder.Repo.delete_all(
        from a in association.assoc,
        where: field(a, ^association.assoc_key) == ^root.id,
        where: not a.id in ^Enum.map(models, &(&1.id))
      )
    end)
  end

  def apply(changemap) do
    changemap
      |> Enum.map(fn {type, changesets} -> {type, apply_changes(changesets)} end)
      |> Enum.into(%{})
  end

  defp apply_changes(changesets) when is_list(changesets), do: Enum.map(changesets, &apply_changes/1)

  defp apply_changes(changeset) do
    if is_nil(Ecto.Changeset.get_field(changeset, :id)) do
      EdgeBuilder.Repo.insert(changeset)
    else
      EdgeBuilder.Repo.update(changeset)
    end
  end
end
