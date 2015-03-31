defmodule EdgeBuilder.LayoutView do
  use EdgeBuilder.Web, :view

  def title_or_default(title) when is_nil(title), do: title_or_default("")
  def title_or_default(title) do
    case String.length(title) do
      0 -> "EdgeBuilder"
      _ -> "#{title} | EdgeBuilder"
    end
  end
end
