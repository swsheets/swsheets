defmodule EdgeBuilder.Repo do
  use Ecto.Repo, otp_app: :edge_builder
  use Scrivener, page_size: 10
end
