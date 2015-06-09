defmodule Ecto.Types.Enumeration do
  def type, do: :string

  def cast(atom) when is_atom(atom), do: {:ok, atom}
  def cast(str) when is_binary(str), do: {:ok, String.to_atom(str)}
  def cast(_), do: :error

  def load(str) when is_binary(str), do: {:ok, String.to_atom(str)}

  def dump(atom) when is_atom(atom), do: {:ok, Atom.to_string(atom)}
  def dump(_), do: :error
end
