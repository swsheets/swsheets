[
  import_deps: [:ecto, :phoenix],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test,web}/**/*.{ex,exs}"],
  subdirectories: ["priv/*/migrations"]
]
