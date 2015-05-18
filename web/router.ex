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
    get "/reference", PageController, :reference
    resources "/characters", CharacterController
    get  "/welcome", SignupController, :welcome
    get  "/password-reset", PasswordResetController, :request
    post  "/password-reset", PasswordResetController, :submit_request
    get  "/password-reset/reset", PasswordResetController, :reset
    post  "/password-reset/reset", PasswordResetController, :submit_reset
    post "/login", SignupController, :login
    post "/logout", SignupController, :logout
    post "/signup", SignupController, :signup
    resource "/user", SettingsController, only: [:edit, :update]
  end
end
