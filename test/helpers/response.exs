defmodule Helpers.Response do

  def selector_contains?(conn, selector, text) do
    conn.resp_body
    |> Floki.find(selector)
    |> Enum.at(0)
    |> to_text
    |> String.contains?(text)

  end

  defp to_text({_, _, children}) do
    Enum.reduce(children, "", fn(x, acc) -> acc <> to_text(x) end)
  end

  defp to_text(str) when is_binary(str) do
    str
  end
end
