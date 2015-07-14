defmodule EdgeBuilder.Changemap do
  import Ecto.Query, only: [from: 2]

  def valid?(changemap = %{root: _changes}) do
    changemap
    |> Map.values
    |> valid?
  end
  def valid?(changeset) when is_map(changeset), do: changeset.valid?
  def valid?(collection) when is_list(collection), do: Enum.all?(collection, &valid?/1)

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

    changemap
  end

  def apply_changes(changemap, association_field \\ nil, parent \\ nil)
  def apply_changes(changemap = %{root: root}, association_field, parent) do
    root = apply_changes(root, association_field, parent)

    changemap
    |> Map.delete(:root)
    |> Enum.map(fn {field, changesets} ->
        {field, apply_changes(changesets, field, root)}
      end)
    |> Enum.into(%{root: root})
  end
  def apply_changes(changesets, association_field, parent) when is_list(changesets), do: Enum.map(changesets, &(apply_changes(&1, association_field, parent)))
  def apply_changes(changeset, association_field, parent) do
    changeset = add_relation(changeset, association_field, parent)

    if is_nil(Ecto.Changeset.get_field(changeset, :id)) do
      EdgeBuilder.Repo.insert!(changeset)
    else
      EdgeBuilder.Repo.update!(changeset)
    end
  end

  defp add_relation(changeset, nil, nil), do: changeset
  defp add_relation(changeset, association_field, parent_model) do
    changeset
    |> Ecto.Changeset.put_change(parent_model.__struct__.__schema__(:association, association_field).assoc_key, parent_model.id)
  end
end
