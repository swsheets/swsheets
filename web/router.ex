defmodule EdgeBuilder.Router do
  use Phoenix.Router
  use Plug.ErrorHandler
  use Sentry.Plug

  pipeline :browser do
    plug :accepts, ~w(html)
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug Plug.DiagnosticCookies
    plug Plug.ScrubEmptyParams
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ~w(json)
    plug :fetch_session
    plug :fetch_flash
    plug Plug.ScrubEmptyParams
  end

  scope "/", EdgeBuilder do
    # Use the default browser stack
    pipe_through :browser

    get "/", PageController, :index
    get "/about", PageController, :about
    get "/supporters", PageController, :supporters
    get "/thank-you", PageController, :thank_you
    get "/thanks", PageController, :thanks
    resources "/c", CharacterController
    resources "/u", ProfileController, only: [:show]
    resources "/v", VehicleController
    get "/my-creations", ProfileController, :my_creations
    get "/welcome", SignupController, :welcome
    get "/forgot-password", PasswordResetController, :request
    post "/forgot-password", PasswordResetController, :submit_request
    get "/password-reset", PasswordResetController, :reset
    post "/password-reset", PasswordResetController, :submit_reset
    post "/login", SignupController, :login
    post "/logout", SignupController, :logout
    post "/signup", SignupController, :signup
    resources "/user", SettingsController, only: [:edit, :update], singleton: true

    post "/test-support/fake-login/:id", TestSupportController, :fake_login
  end

  scope "/api", EdgeBuilder.API do
    pipe_through :api
    resources "/characters", CharacterController, only: [:update]
    resources "/vehicles", VehicleController, only: [:update]
  end
end
