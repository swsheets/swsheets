defmodule EdgeBuilder.Mixfile do
  use Mix.Project

  def project do
    [app: :edge_builder,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: ["lib", "web"],
     compilers: [:phoenix] ++ Mix.compilers,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {EdgeBuilder, []},
     applications: [:phoenix, :cowboy, :logger, :postgrex, :ecto, :httpoison]]
  end

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 0.13.0"},
     {:phoenix_ecto, "~> 0.4"},
     {:phoenix_html, "~> 1.0"},
     {:cowboy, "~> 1.0"},
     {:postgrex, "~> 0.6"},
     {:ecto, "~> 0.11"},
     {:scrivener, "~> 0.6"},
     {:comeonin, "~> 0.8"},
     {:httpoison, "~> 0.6"},
     {:mock, "~> 0.1", only: :test},
     {:factory_girl_elixir, "~> 0.1", only: :test},
     {:floki, "~> 0.1", only: :test},
     {:ex_spec, "~> 0.3", only: :test}]
  end
end
