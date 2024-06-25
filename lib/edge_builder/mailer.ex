defmodule EdgeBuilder.Mailer do
  alias EdgeBuilder.TinyJMAPClient

  defp jmap_hostname, do: Application.get_env(:edge_builder, :jmap_hostname)
  defp jmap_username, do: Application.get_env(:edge_builder, :jmap_username)
  defp jmap_token, do: Application.get_env(:edge_builder, :jmap_token)

  defp load_text(opts) do
    EEx.eval_file("email_templates/#{opts[:template]}.eex", opts)
  end

  defp load_subject(opts) do
    EEx.eval_file("email_templates/#{opts[:template]}_subject.eex", opts)
  end

  def send_email(opts) do
    client = TinyJMAPClient.new(jmap_hostname(), jmap_username(), jmap_token())
    client = TinyJMAPClient.get_account_id(client)

    call = %{
      "using" => ["urn:ietf:params:jmap:core", "urn:ietf:params:jmap:mail"],
      "methodCalls" => [
        ["Mailbox/query", %{"accountId" => client.account_id}, "a"]
      ]
    }

    query_res =
      TinyJMAPClient.make_jmap_call(client, call)

    draft_mailbox_id =
      query_res["methodResponses"]
      |> List.first()
      |> Enum.at(1)
      |> Map.get("ids")
      |> hd()

    if String.length(draft_mailbox_id) == 0 do
      raise "No draft mailbox ID found"
    end

    body = load_text(opts)

    draft = %{
      "from" => [%{"email" => client.username}],
      "to" => [%{"email" => Keyword.get(opts, :to)}],
      "subject" => load_subject(opts),
      "keywords" => %{"$draft" => true},
      "mailboxIds" => %{draft_mailbox_id => true},
      "bodyValues" => %{"body" => %{"value" => body, "charset" => "utf-8"}},
      "textBody" => [%{"partId" => "body", "type" => "text/plain"}]
    }

    client = TinyJMAPClient.get_identity_id(client)

    _create_res =
      TinyJMAPClient.make_jmap_call(client, %{
        "using" => [
          "urn:ietf:params:jmap:core",
          "urn:ietf:params:jmap:mail",
          "urn:ietf:params:jmap:submission"
        ],
        "methodCalls" => [
          [
            "Email/set",
            %{
              "accountId" => client.account_id,
              "create" => %{"draft" => draft}
            },
            "a"
          ],
          [
            "EmailSubmission/set",
            %{
              "accountId" => client.account_id,
              "onSuccessDestroyEmail" => ["#sendIt"],
              "create" => %{
                "sendIt" => %{
                  "emailId" => "#draft",
                  "identityId" => client.identity_id
                }
              }
            },
            "b"
          ]
        ]
      })
  end
end
