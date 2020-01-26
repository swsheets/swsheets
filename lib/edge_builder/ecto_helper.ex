defmodule EdgeBuilder.EctoHelper do
  @moduledoc """
  Provides helper functions
  """

  @doc """
  Prettifies changeset error messages.
  By default `changeset.errors` returns errors as keyword list, where key is name of the field
  and value is part of message. For example, `[body: "is required"]`.
  This method transforms errors in list which is ready to pass it, for example, in response of
  a JSON API request.
  ## Example of basic usage
  ```elixir
  EctoHelper.pretty_errors([body: "is required"]) # => ["Body is required"]
  ```
  ## Example of usage with interpolations
  ```elixir
  EctoHelper.pretty_errors([login: {"should be at most %{count} character(s)", [count: 10]}])
  # => ["Login should be at most 10 character(s)"]
  ```
  """
  @spec pretty_errors(Map.t()) :: [String.t()]
  def pretty_errors(errors) do
    errors
    |> Enum.map(&do_prettify/1)
  end

  defp do_prettify({field_name, message}) when is_bitstring(message) do
    human_field_name =
      field_name
      |> Atom.to_string()
      |> String.replace("_", " ")
      |> String.capitalize()

    human_field_name <> " " <> message
  end

  defp do_prettify({field_name, {message, variables}}) do
    compound_message = do_interpolate(message, variables)
    do_prettify({field_name, compound_message})
  end

  defp do_interpolate(string, [{name, value} | rest]) do
    n = Atom.to_string(name)
    msg = String.replace(string, "%{#{n}}", do_to_string(value))
    do_interpolate(msg, rest)
  end

  defp do_interpolate(string, []), do: string

  defp do_to_string(value) when is_integer(value), do: Integer.to_string(value)
  defp do_to_string(value) when is_bitstring(value), do: value
  defp do_to_string(value) when is_atom(value), do: Atom.to_string(value)
end
