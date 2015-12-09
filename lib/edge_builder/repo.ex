defmodule EdgeBuilder.Repo do
  use Ecto.Repo, otp_app: :edge_builder
  use Scrivener, page_size: 10
  import Ecto.Query, only: [from: 2]

  def count(module) do
    one(from u in module, select: count(u.id))
  end
end
