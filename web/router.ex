defmodule EdgeBuilder.Router do
  use Phoenix.Router

  pipeline :browser do
    plug :accepts, ~w(html)
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug Plug.ScrubEmptyParams
  end

  pipeline :api do
    plug :accepts, ~w(json)
  end

  scope "/", EdgeBuilder do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/about", PageController, :about
    get "/thanks", PageController, :thanks
    resources "/c", CharacterController
    resources "/u", ProfileController, only: [:show]
    resources "/v", VehicleController, only: [:new, :create]
    get  "/welcome", SignupController, :welcome
    get  "/forgot-password", PasswordResetController, :request
    post  "/forgot-password", PasswordResetController, :submit_request
    get  "/password-reset", PasswordResetController, :reset
    post  "/password-reset", PasswordResetController, :submit_reset
    post "/login", SignupController, :login
    post "/logout", SignupController, :logout
    post "/signup", SignupController, :signup
    resource "/user", SettingsController, only: [:edit, :update]
  end
end
