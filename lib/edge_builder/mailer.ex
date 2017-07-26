defmodule EdgeBuilder.Mailer do
  defp domain, do: Application.get_env(:edge_builder, :mailgun_domain)
  defp from, do: Application.get_env(:edge_builder, :mailgun_from)
  defp api_key, do: Application.get_env(:edge_builder, :mailgun_api_key)

  defp load_text(opts) do
    EEx.eval_file "email_templates/#{opts[:template]}.eex", opts
  end

  defp load_subject(opts) do
    EEx.eval_file "email_templates/#{opts[:template]}_subject.eex", opts
  end

  def send_email(opts) do
    case domain() do
      nil -> load_text(opts)
      _ -> HTTPoison.post! "https://api:#{api_key()}@api.mailgun.net/v3/#{domain()}/messages", {:form, [from: from(), to: Keyword.get(opts, :to), subject: load_subject(opts), text: load_text(opts)]}
    end
  end
end
