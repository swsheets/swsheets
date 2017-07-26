defmodule EdgeBuilder.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  imports other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use EdgeBuilder.TestCase
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      # Alias the data repository and import query/model functions
      alias EdgeBuilder.Repo
      import Ecto.Query, only: [from: 2]

      # Import URL helpers from the router
      import EdgeBuilder.Router.Helpers

      # The default endpoint for testing
      @endpoint EdgeBuilder.Endpoint

      def is_redirect_to?(conn, path) do
        Enum.member?(conn.resp_headers, {"location", path}) 
      end

      def requires_authentication?(conn) do
        is_redirect_to?(conn, "/welcome")
      end

      def authenticate_as(conn, user) do
        conn = post(conn, "/test-support/fake-login/#{user.id}") |> recycle()
      end

      def json_put(conn, path, params \\ nil) do
        params = if is_nil(params) do
          params
        else
          Poison.encode!(params)
        end

        conn
        |> put_req_header("content-type", "application/json")
        |> put(path, params)
      end

      def api(conn) do
        put_req_header(conn, "content-type", "application/json")
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(EdgeBuilder.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(EdgeBuilder.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
