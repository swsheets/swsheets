defmodule EdgeBuilder.TestCase do
  use ExUnit.CaseTemplate

  defmacro __using__(_opts) do
    quote do
      use ExSpec

      def has_error?(changeset, field, error_text) do
        Keyword.get_values(changeset.errors, field)
        |> Enum.map( fn {message, _} -> message end )
        |> Enum.member?(error_text)
      end
    end
  end
end
