defmodule Plug.DiagnosticCookies do
  @expiry_in_ten_years (10 * 365 * 24 * 60 * 60)

  require Logger

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> generate_cookie("b", max_age: @expiry_in_ten_years)
    |> generate_cookie("s")
  end

  defp generate_cookie(conn, name, opts \\ []) do
    if is_nil(conn.cookies) || is_nil(conn.cookies[:name]) do
      value = Ecto.UUID.generate
      Logger.metadata([{String.to_atom(name <> "_cookie"), value}])
      Plug.Conn.put_resp_cookie(conn, name, value, opts)
    else
      value = conn.cookies[:name]
      Logger.metadata([{String.to_atom(name <> "_cookie"), value}])
      conn
    end
  end
end
