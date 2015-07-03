use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :edge_builder, EdgeBuilder.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :edge_builder, EdgeBuilder.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "edgebuilder_test",
  size: 1,
  max_overflow: false,
  pool: Ecto.Adapters.SQL.Sandbox
