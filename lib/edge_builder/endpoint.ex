defmodule EdgeBuilder.Endpoint do
  use Phoenix.Endpoint, otp_app: :edge_builder
  use Sentry.Phoenix.Endpoint

  plug(Plug.Static, at: "/", from: :edge_builder, only: ~w(css images js fonts icons))

  plug(Plug.Logger)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  @expiry_in_ten_years 10 * 365 * 24 * 60 * 60
  plug(Plug.Session,
    store: :cookie,
    key: "_edge_builder_key",
    signing_salt: "YC5iCZqf",
    encryption_salt: "UH3U4ow6",
    max_age: @expiry_in_ten_years
  )

  plug(EdgeBuilder.Router)
end
