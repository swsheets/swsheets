use Mix.Config

config :edge_builder, EdgeBuilder.Endpoint,
  http: [port: System.get_env("PORT") || 4001]

# Print only warnings and errors during test
config :logger, level: :warn

config :edge_builder, EdgeBuilder.Repo,
  database: "edgebuilder_test",
  size: 1,
  max_overflow: 0
