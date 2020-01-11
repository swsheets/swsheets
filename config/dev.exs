use Mix.Config

config :edge_builder, EdgeBuilder.Endpoint,
  http: [port: System.get_env("PORT") || 4000],
  debug_errors: true,
  code_reloader: true

config :edge_builder,
  mailgun_domain: System.get_env("MAILGUN_DOMAIN"),
  mailgun_from: System.get_env("MAILGUN_FROM"),
  mailgun_api_key: System.get_env("MAILGUN_API_KEY")

# Enables code reloading for development
config :phoenix, :code_reloader, true

config :edge_builder, EdgeBuilder.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

config :edge_builder, EdgeBuilder.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
