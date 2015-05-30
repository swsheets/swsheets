# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :edge_builder, EdgeBuilder.Endpoint,
  root: Path.expand("..", __DIR__),
  url: [host: "localhost"],
  secret_key_base: "9gHweeZJaqUL1PGBXTxahiuf9fQuc5FJvN5AfL3XJpG5UkKkH8g/ApPrixTs67nE",
  debug_errors: false,
  pubsub: [name: EdgeBuilder.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :edge_builder, EdgeBuilder.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "edgebuilder_development",
  username: "pair",
  hostname: "localhost"

config :edge_builder,
  application_name: "SWSheets",
  application_base_url: "http://swsheets.com"

config :edge_builder, EdgeBuilder.Router,
  session: [store: :cookie, key: "46587ade059260088e5307d26f8097fd"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
