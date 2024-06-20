defmodule Helpers.FlokiExt do
  def element(conn, selector) do
    conn.resp_body
    |> find(selector)
    |> Enum.at(0)
  end

  def find(parseable, selector) do
    Floki.find(parseable, selector)
  end

  def text({_, _, children}) do
    Enum.reduce(children, "", fn x, acc -> acc <> text(x) end)
  end

  def text(str) when is_binary(str), do: str

  def attribute([node], attribute_name), do: attribute(node, attribute_name)

  def attribute({_, attributes, _}, attribute_name) do
    {_, value} = List.keyfind(attributes, attribute_name, 0) || {nil, nil}
    value
  end
end
