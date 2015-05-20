defmodule EdgeBuilder.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use EdgeBuilder.Web, :controller
      use EdgeBuilder.Web, :view

  Keep the definitions in this module short and clean,
  mostly focused on imports, uses and aliases.
  """

  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      # Import URL helpers from the router
      import EdgeBuilder.Router.Helpers

      # Import all HTML functions (forms, tags, etc)
      use Phoenix.HTML
      import EdgeBuilder.ViewHelpers
    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      # Alias the data repository as a convenience
      alias EdgeBuilder.Repo

      # Import URL helpers from the router
      import EdgeBuilder.Router.Helpers

      def render_404(conn), do: conn |> put_status(:not_found) |> render(EdgeBuilder.ErrorView, "404.html")
    end
  end

  def model do
    quote do
      use Ecto.Model
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
