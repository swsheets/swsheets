use Mix.Config

config :edge_builder, EdgeBuilder.Endpoint,
  http: [port: System.get_env("PORT") || 4000],
  debug_errors: true

config :edge_builder,
  mailgun_domain: System.get_env("MAILGUN_DOMAIN"),
  mailgun_from: System.get_env("MAILGUN_FROM"),
  mailgun_api_key: System.get_env("MAILGUN_API_KEY")

# Enables code reloading for development
config :phoenix, :code_reloader, true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
