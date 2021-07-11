defmodule EdgeBuilder.ErrorView do
  use EdgeBuilder.Web, :view

  def render("404.html", _assigns) do
    render("404_page.html", %{})
  end

  def render("500.html", _assigns) do
    render("500_page.html", %{})
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_, assigns) do
    render("500.html", assigns)
  end
end
