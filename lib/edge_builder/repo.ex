defmodule EdgeBuilder.Repo do
  use Ecto.Repo,
    adapter: Ecto.Adapters.Postgres,
    otp_app: :edge_builder
end
