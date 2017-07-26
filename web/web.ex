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
      use EdgeBuilder.ViewHelpers
      import Inflex, only: [inflect: 2]
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1, view_template: 1]
    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      # Alias the data repository as a convenience
      alias EdgeBuilder.Repo

      # Import URL helpers from the router
      import EdgeBuilder.Router.Helpers

      def set_current_user(conn, user) do
        conn
          |> put_session(:current_user_id, user.id)
          |> put_session(:current_user_username, user.username)
      end

      def current_user_id(conn) do
        get_session(conn, :current_user_id)
      end

      def is_owner?(conn, model) do
        model.user_id == current_user_id(conn)
      end

      def render_404(conn), do: conn |> put_status(:not_found) |> render(EdgeBuilder.ErrorView, "404.html")
    end
  end

  def model do
    quote do
      use Ecto.Schema
      alias EdgeBuilder.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
