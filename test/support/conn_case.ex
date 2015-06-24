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
      import Ecto.Model
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

      # This is a somewhat ridiculous way to authenticate as a user - however, it's the only way that doesn't require foreknowledge
      # of the user's password
      def authenticate_as(conn, user) do
        user = Factories.UserFactory.add_password_reset_token(user)

        conn
        |> post("/password-reset", %{"password_reset" => %{"password" => "123456789012", "password_confirmation" => "123456789012", "token" => user.password_reset_token}})
      end
    end
  end

  setup tags do
    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(EdgeBuilder.Repo, [])
    end

    :ok
  end
end
