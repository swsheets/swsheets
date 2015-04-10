defmodule Helpers.FlokiExt do

  def element(conn, selector) do
    conn.resp_body
    |> find(selector)
    |> Enum.at(0)
  end

  def find(parseable, selector) do
    if String.starts_with?(selector, "[") do
      [_ | [attribute, value]] = Regex.run ~r{\[([^=]*)=(.*)\]}, selector
      find_by_attribute(Floki.parse(parseable), attribute, value)
    else
      Floki.find(parseable, selector)
    end
  end

  def find_by_attribute(node = {_, attributes, children}, attribute, value) do
    matches = Enum.flat_map(children, fn(c) -> find_by_attribute(c, attribute, value) end)

    if List.keymember?(attributes, attribute, 0) do
      [node | matches]
    else
      matches
    end
  end
  def find_by_attribute(_,_,_), do: []

  def text({_, _, children}) do
    Enum.reduce(children, "", fn(x, acc) -> acc <> text(x) end)
  end

  def text(str) when is_binary(str), do: str

  def attribute({_, attributes, _}, attribute_name) do
    {_, value} = List.keyfind(attributes, attribute_name, 0) || {nil, nil}
    value
  end
end
