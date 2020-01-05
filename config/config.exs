# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :edge_builder,
  ecto_repos: [EdgeBuilder.Repo]

config :phoenix, :json_library, Poison

# Configures the endpoint
config :edge_builder, EdgeBuilder.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9gHweeZJaqUL1PGBXTxahiuf9fQuc5FJvN5AfL3XJpG5UkKkH8g/ApPrixTs67nE",
  debug_errors: false,
  render_errors: [view: EdgeBuilder.ErrorView, accepts: ~w(html json)],
  code_reloader: false,
  pubsub: [name: EdgeBuilder.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :b_cookie, :s_cookie]

config :edge_builder, EdgeBuilder.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USER") || "pair",
  password: System.get_env("DB_PASSWORD") || "",
  database: System.get_env("DB_NAME") || "edgebuilder_development",
  hostname: System.get_env("DB_HOST") || "localhost",
  port: System.get_env("DB_PORT") || 5432,
  pool_size: 10

config :edge_builder,
  application_name: "SWSheets"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
