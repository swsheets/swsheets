defmodule EdgeBuilder.Repo do
  use Ecto.Repo, otp_app: :edge_builder, adapter: Ecto.Adapters.Postgres
  use Scrivener, page_size: 10
end
