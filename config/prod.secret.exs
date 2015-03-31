use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :edge_builder, EdgeBuilder.Endpoint,
  secret_key_base: "JLUVymEw6/puWWtUol0ECoJaEC+jEoo9xiz7f0h3lwoEgCmzX49u0KkRXjmJIfAC"

# Configure your database
config :edge_builder, EdgeBuilder.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "edgebuilder_prod"
