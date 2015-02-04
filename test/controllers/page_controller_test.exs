defmodule EdgeBuilder.Controllers.PageControllerTest do
  use ExSpec
  use Plug.Test

  @opts EdgeBuilder.Router.init []

  def with_session(conn) do
    session_opts = Plug.Session.init(store: :cookie, key: "_app",
    encryption_salt: "abc", signing_salt: "abc")
    conn
    |> Map.put(:secret_key_base, String.duplicate("abcdefgh", 8))
    |> Plug.Session.call(session_opts)
    |> Plug.Conn.fetch_session()
    |> Plug.Conn.fetch_params()
  end

  describe "reference" do
    it "renders the reference HTML" do
      conn = conn(:get, "/reference") |> with_session
      conn = EdgeBuilder.Router.call(conn, @opts)

      assert String.contains?(conn.resp_body, "Character Name")
    end
  end
end
