defmodule Mix.Tasks.AddContributor do
  use Mix.Task

  alias EdgeBuilder.Models.User

  @shortdoc "Add a contributor to the app. Arguments: USERNAME <pull_request|bug>"

  @moduledoc @shortdoc
  def run(args)
  def run([username, "pull_request"]) do
    set_contribution(username, %{pull_requested_at: DateTime.utc_now()})
  end
  def run([username, "bug"]) do
    set_contribution(username, %{bug_reported_at: DateTime.utc_now()})
  end

  defp set_contribution(username, changes) do
    Mix.Task.run "app.start"
    User.by_username(username)
    |> User.changeset(:contributions, changes)
    |> EdgeBuilder.Repo.update!
  end
end
