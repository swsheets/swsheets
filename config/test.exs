use Mix.Config

config :edge_builder, EdgeBuilder.Endpoint,
  http: [port: 4001], server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :edge_builder, EdgeBuilder.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "edgebuilder_test",
  size: 1,
  max_overflow: false
