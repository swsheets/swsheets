defmodule EdgeBuilder.TinyJMAPClient do
  @moduledoc """
  The tiniest JMAP client you can imagine.
  """

  defstruct hostname: nil,
            username: nil,
            token: nil,
            session: nil,
            api_url: nil,
            account_id: nil,
            identity_id: nil

  @doc """
  Initialize using a hostname, username and bearer token.
  """
  def new(hostname, username, token)
      when is_binary(hostname) and is_binary(username) and is_binary(token) do
    if String.length(hostname) > 0 and String.length(username) > 0 and String.length(token) > 0 do
      %EdgeBuilder.TinyJMAPClient{hostname: hostname, username: username, token: token}
    else
      raise ArgumentError, "Hostname, username, and token must be non-empty strings."
    end
  end

  @doc """
  Get the JMAP session.
  """
  def get_session(client) do
    case client.session do
      nil ->
        url = "https://#{client.hostname}/.well-known/jmap"

        headers = [
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer #{client.token}"}
        ]

        case HTTPoison.get(url, headers, follow_redirect: true) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            session = Poison.decode!(body)
            %{client | session: session, api_url: session["apiUrl"]}

          {:error, %HTTPoison.Error{reason: reason}} ->
            raise "HTTP request failed: #{reason}"
        end

      _session ->
        client
    end
  end

  @doc """
  Return the updated client with the accountId for the account matching the username.
  """
  def get_account_id(client) do
    case client.account_id do
      nil ->
        client = get_session(client)

        account_id =
          client.session["primaryAccounts"]["urn:ietf:params:jmap:mail"]

        %{client | account_id: account_id}

      _account_id ->
        client
    end
  end

  @doc """
  Return the updated client with the identityId for an address matching the username.
  """
  def get_identity_id(client) do
    case client.identity_id do
      nil ->
        call = %{
          "using" => ["urn:ietf:params:jmap:core", "urn:ietf:params:jmap:submission"],
          "methodCalls" => [
            ["Identity/get", %{"accountId" => client.account_id}, "i"]
          ]
        }

        identity_res = make_jmap_call(client, call)

        identity_id =
          identity_res["methodResponses"]
          |> List.first()
          |> Enum.at(1)
          |> Map.get("list")
          |> Enum.find(fn i -> i["email"] == client.username end)
          |> Map.get("id")

        %{client | identity_id: identity_id}

      _identity_id ->
        client
    end
  end

  @doc """
  Make a JMAP POST request to the API, returning the response as a map.
  """
  def make_jmap_call(client, call) do
    url = client.api_url

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{client.token}"}
    ]

    case HTTPoison.post(url, Poison.encode!(call), headers, follow_redirect: true) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Poison.decode!(body)

      {:error, %HTTPoison.Error{reason: reason}} ->
        raise "HTTP request failed: #{reason}"
    end
  end
end
