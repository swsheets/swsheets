defmodule EdgeBuilder.Mixfile do
  use Mix.Project

  def project do
    [
      app: :edge_builder,
      version: "2.19.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {EdgeBuilder, []}]
  end

  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_), do: ["lib", "web"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [
      {:phoenix, "~> 1.7.12"},
      {:phoenix_pubsub, "~> 2.1.3"},
      {:phoenix_ecto, "~> 4.6.1"},
      {:phoenix_live_reload, "~> 1.5.3", only: :dev},
      {:phoenix_view, "~> 2.0"},
      {:ecto_sql, "~> 3.11.3"},
      {:plug, "~> 1.16", override: true},
      {:postgrex, "~> 0.18.0"},
      {:phoenix_html, "~> 4.1.1"},
      {:phoenix_html_helpers, "~> 1.0"},
      {:gettext, "~> 0.24.0"},
      {:ex_spec, "~> 2.0", only: :test},
      {:plug_cowboy, "~> 2.7"},
      {:scrivener_ecto, "~> 2.7"},
      {:comeonin, "~> 5.4"},
      {:bcrypt_elixir, "~> 3.1"},
      {:httpoison, "~> 2.2.1"},
      {:poison, "~> 6.0"},
      {:sentry, "~> 10.6"},
      {:inflex, "~> 2.1"},
      {:mock, "~> 0.3.8", only: :test},
      {:excoveralls, "~> 0.18.1", only: :test},
      {:floki, "~> 0.36.2", only: :test}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
