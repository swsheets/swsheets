defmodule Plug.ScrubEmptyParams do
  def init(opts), do: opts

  def call(conn = %{params: params}, opts) do
    %{conn | params: scrub_params(params)}
  end

  defp scrub_params(params) do
    Enum.map(params, fn
      {k, ""} -> {k, nil}
      {k, m} when is_map(m) -> {k, scrub_params(m)}
      pair    -> pair
    end) |> Enum.into(%{})
  end
end
