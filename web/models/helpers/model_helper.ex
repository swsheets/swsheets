defmodule EdgeBuilder.Models.Helpers.ModelHelper do
  @spec validate_length_many(
          changeset :: Ecto.Changeset.t(),
          fields :: [atom()],
          max_length :: integer
        ) :: Ecto.Changeset.t()
  def validate_length_many(%Ecto.Changeset{} = changeset, fields, max_length)
      when is_list(fields) do
    Enum.reduce(fields, changeset, fn field, changeset ->
      Ecto.Changeset.validate_length(changeset, field, max: max_length)
    end)
  end
end
