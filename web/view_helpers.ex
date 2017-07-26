defmodule EdgeBuilder.ViewHelpers do
  defmacro __using__(_opts) do
    quote do
      import Extensions.Changeset, only: [get_field: 2]

      def application_name, do: Application.get_env(:edge_builder, :application_name)

      def format_date(nil), do: nil
      def format_date(date) do
        NaiveDateTime.to_erl(date)
        |> Ecto.DateTime.from_erl
        |> Ecto.DateTime.to_date
        |> Ecto.Date.to_string
      end

      def profile_links(_, [], _), do: []
      def profile_links(conn, [user], size), do: profile_link(conn, user, size)
      def profile_links(conn, [user | rest], size) do
        [profile_link(conn, user, size), ", ", profile_links(conn, rest, size)]
      end

      def profile_link(conn, user, size) do
        render EdgeBuilder.ProfileView, "profile_link.html", conn: conn, user: user, size: size
      end

      def options(value, options) do
        Enum.map(options, fn opt ->
          "<option#{if value == opt, do: " selected"}>#{opt}</option>"
        end) |> raw
      end

      def render_text(changeset, field) do
        {:safe, escaped_value} = Ecto.Changeset.get_field(changeset, field) |> Phoenix.HTML.html_escape

        {:safe, String.replace(escaped_value, "\n", "<br>")}
      end

      def in_display_order(coll) do
        Enum.sort(coll, &(get_field(&1, :display_order) < get_field(&2, :display_order)))
      end
    end
  end
end
