defmodule Factories.BaseFactory do
  def initialize do
    :ets.new(:factories, [:named_table, :public])
    :ets.insert(:factories, {:counter, 0})
  end

  defmacro __using__(_opts) do
    quote do
      def next_counter do
        :ets.update_counter(:factories, :counter, 1)
      end

      def parameterize(map) do
        Enum.map(map, &parameterized/1)
        |> Enum.into(%{})
      end

      defp parameterized({key, val})
      when is_atom(key) do
        {Atom.to_string(key), val}
      end
      defp parameterized(attr), do: attr
    end
  end
end
