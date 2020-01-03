defmodule TwittercloneWeb.Router do
  use TwittercloneWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TwittercloneWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/single_user", SingleUserController, :index
    get "/simulation", SimulationController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", TwittercloneWeb do
  #   pipe_through :api
  # end
end
