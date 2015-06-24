defmodule EdgeBuilder.TestCase do
  use ExUnit.CaseTemplate

  defmacro __using__(_opts) do
    quote do
      use ExSpec

      def has_error?(changeset, field, error_text) do
        Keyword.get_values(changeset.errors, field)
        |> Enum.member?(error_text)
      end
    end
  end

  setup do
    Ecto.Adapters.SQL.restart_test_transaction(EdgeBuilder.Repo)
    :ok
  end
end
