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

    changemap = Map.delete(changemap, :root)

    Enum.each(changemap, fn {field, models} ->
      association = root_model.__schema__(:association, field)

      missing_children_ids = EdgeBuilder.Repo.all(
        from a in association.related,
        where: field(a, ^association.related_key) == ^root.id,
        where: not a.id in ^Enum.map(models, &get_id/1)
      ) |> Enum.map(&get_id/1)

      delete_with_children(association.related, missing_children_ids)

      Enum.each(models, &delete_missing/1)
    end)

    changemap
  end
  def delete_missing(_), do: nil

  defp get_id(%{root: model}), do: model.id
  defp get_id(model), do: model.id

  defp delete_with_children(model, ids_to_delete) do
    model.__schema__(:associations)
    |> Enum.map(&(model.__schema__(:association, &1)))
    |> Enum.filter( fn
      %Ecto.Association.Has{} -> true
      _ -> false
    end)
    |> Enum.each( fn(association) -> 
      missing_children_ids = EdgeBuilder.Repo.all(
        from a in association.related,
        where: field(a, ^association.related_key) in ^ids_to_delete
      ) |> Enum.map(&get_id/1)

      delete_with_children(association.related, missing_children_ids)
    end)

    EdgeBuilder.Repo.delete_all(
      from a in model,
      where: a.id in ^ids_to_delete
    )
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

    EdgeBuilder.RepoService.upsert(changeset)
  end

  defp add_relation(changeset, nil, nil), do: changeset
  defp add_relation(changeset, association_field, parent_model) do
    changeset
    |> Ecto.Changeset.put_change(parent_model.__struct__.__schema__(:association, association_field).related_key, parent_model.id)
  end
end
