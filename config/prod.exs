use Mix.Config

config :edge_builder,
  mailgun_domain: System.get_env("MAILGUN_DOMAIN"),
  mailgun_from: System.get_env("MAILGUN_FROM"),
  mailgun_api_key: System.get_env("MAILGUN_API_KEY")

# For production, we configure the host to read the PORT
# from the system environment. Therefore, you will need
# to set PORT=80 before running your server.
#
# You should also configure the url host to something
# meaningful, we use this information when generating URLs.
config :edge_builder, EdgeBuilder.Endpoint,
  http: [port: {:system, "PORT"}],
  check_origin: true,
  url: [host: System.get_env("WEB_HOST"), port: 80],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  cache_static_manifest: "priv/static/cache_manifest.json"

config :edge_builder, EdgeBuilder.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: toBool(System.get_env("POSTGRES_SSL") || "false", false)

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section:
#
#  config:edge_builder, EdgeBuilder.Endpoint,
#    ...
#    https: [port: 443,
#            keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#            certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables point to a file on
# disk for the key and cert.

# Do not print debug messages in production
config :logger, level: :info

toBool = fn
  "true", _ -> true
  "false", _ -> false
  nil, default -> default
end
