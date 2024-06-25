defmodule EdgeBuilder.TinyJMAPClientTest do
  use ExUnit.Case, async: true
  import Mock

  alias EdgeBuilder.TinyJMAPClient

  @hostname "api.fastmail.com"
  @username "test@example.com"
  @token "test_token"

  setup do
    client = TinyJMAPClient.new(@hostname, @username, @token)
    {:ok, client: client}
  end

  test "get_session/1 fetches the session and updates the client", %{client: client} do
    session_response = %{
      "apiUrl" => "https://api.fastmail.com/jmap/",
      "primaryAccounts" => %{"urn:ietf:params:jmap:mail" => "account_id"}
    }

    with_mock HTTPoison,
      get: fn _url, _headers, _opts ->
        {:ok, %HTTPoison.Response{status_code: 200, body: Poison.encode!(session_response)}}
      end do
      updated_client = TinyJMAPClient.get_session(client)

      assert updated_client.session == session_response
      assert updated_client.api_url == "https://api.fastmail.com/jmap/"
    end
  end

  test "get_account_id/1 fetches the account_id and updates the client", %{client: client} do
    session_response = %{
      "apiUrl" => "https://api.fastmail.com/jmap/",
      "primaryAccounts" => %{"urn:ietf:params:jmap:mail" => "account_id"}
    }

    with_mock HTTPoison,
      get: fn _url, _headers, _opts ->
        {:ok, %HTTPoison.Response{status_code: 200, body: Poison.encode!(session_response)}}
      end do
      updated_client = TinyJMAPClient.get_account_id(client)

      assert updated_client.account_id == "account_id"
    end
  end

  test "get_identity_id/1 fetches the identity_id and updates the client", %{client: client} do
    session_response = %{
      "apiUrl" => "https://api.fastmail.com/jmap/",
      "primaryAccounts" => %{"urn:ietf:params:jmap:mail" => "account_id"}
    }

    identity_response = %{
      "methodResponses" => [
        [
          "Identity/get",
          %{
            "list" => [%{"id" => "identity_id", "email" => @username}]
          },
          "i"
        ]
      ]
    }

    with_mock HTTPoison,
      get: fn _url, _headers, _opts ->
        {:ok, %HTTPoison.Response{status_code: 200, body: Poison.encode!(session_response)}}
      end,
      post: fn _url, _body, _headers, _opts ->
        {:ok, %HTTPoison.Response{status_code: 200, body: Poison.encode!(identity_response)}}
      end do
      updated_client =
        client
        |> TinyJMAPClient.get_account_id()
        |> TinyJMAPClient.get_identity_id()

      assert updated_client.identity_id == "identity_id"
    end
  end

  test "make_jmap_call/2 makes a POST request and returns the response", %{client: client} do
    call = %{"methodCalls" => [["Identity/get", %{"accountId" => "account_id"}, "i"]]}
    api_response = %{"methodResponses" => [["Identity/get", %{"list" => []}, "i"]]}

    with_mock HTTPoison,
      post: fn _url, _body, _headers, _opts ->
        {:ok, %HTTPoison.Response{status_code: 200, body: Poison.encode!(api_response)}}
      end do
      client = %{client | api_url: "https://api.fastmail.com/jmap/", token: "test_token"}
      response = TinyJMAPClient.make_jmap_call(client, call)

      assert response == api_response
    end
  end
end
