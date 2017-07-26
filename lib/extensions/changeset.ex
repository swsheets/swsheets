defmodule Extensions.Changeset do
  def take(changeset_or_model, keys) do
    Enum.map(keys, fn(k) -> {k, get_field(changeset_or_model, k)} end)
    |> Enum.into(%{})
  end

  def get_field(changemap = %{root: model}, key) do
    case Map.fetch(changemap, key) do
      {:ok, value} -> value
      :error -> get_field(model, key)
    end
  end
  def get_field(changeset_or_model, key) do
    case Map.fetch(changeset_or_model, key) do
      {:ok, value} -> value
      :error -> Ecto.Changeset.get_field(changeset_or_model, key)
    end
  end
end
