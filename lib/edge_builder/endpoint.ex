defmodule EdgeBuilder.Endpoint do
  use Phoenix.Endpoint, otp_app: :edge_builder

  plug Plug.Static,
    at: "/", from: :edge_builder,
    only: ~w(css images js fonts
      favicon-16x16.png
      android-chrome-72x72.png
      mstile-150x150.png
      mstile-310x150.png
      mstile-310x310.png
      android-chrome-96x96.png
      android-chrome-192x192.png
      apple-touch-icon-152x152.png
      apple-touch-icon-76x76.png
      android-chrome-48x48.png
      favicon.ico
      favicon-96x96.png
      favicon-32x32.png
      apple-touch-icon-180x180.png
      apple-touch-icon-60x60.png
      apple-touch-icon-72x72.png
      apple-touch-icon.png
      apple-touch-icon-120x120.png
      manifest.json
      apple-touch-icon-114x114.png
      apple-touch-icon-precomposed.png
      mstile-144x144.png
      browserconfig.xml
      apple-touch-icon-144x144.png
      android-chrome-144x144.png
      favicon-194x194.png
      android-chrome-36x36.png
      apple-touch-icon-57x57.png
      mstile-70x70.png
    )

  plug Plug.Logger

  # Code reloading will only work if the :code_reloader key of
  # the :phoenix application is set to true in your config file.
  if code_reloading?, do: plug Phoenix.CodeReloader

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  @expiry_in_ten_years (10 * 365 * 24 * 60 * 60)
  plug Plug.Session,
    store: :cookie,
    key: "_edge_builder_key",
    signing_salt: "YC5iCZqf",
    encryption_salt: "UH3U4ow6",
    max_age: @expiry_in_ten_years

  plug EdgeBuilder.Router
end
