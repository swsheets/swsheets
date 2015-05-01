defmodule Plug.Authentication do
  alias EdgeBuilder.Repo
  alias EdgeBuilder.Models.User

  def init(opts), do: opts

  def call(conn, opts) do
    case Keyword.get(opts, :only) do
      nil -> ensure_authenticated(conn)
      actions -> if Enum.member?(actions, conn.private.phoenix_action), do: ensure_authenticated(conn), else: conn
    end
  end

  defp ensure_authenticated(conn) do
    case Plug.Conn.get_session(conn, :current_user_id) do
      nil -> prompt_for_login(conn)
      user_id -> ensure_user(conn, user_id)
    end
  end

  defp ensure_user(conn, user_id) do
    case Repo.get(User, user_id) do
      nil -> prompt_for_login(conn)
      user -> Plug.Conn.put_private(conn, :current_user, user)
    end
  end

  defp prompt_for_login(conn) do
    Phoenix.Controller.redirect(conn, to: "/welcome") |> Plug.Conn.halt
  end
end
