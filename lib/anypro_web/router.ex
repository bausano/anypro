defmodule AnyproWeb.Router do
  use AnyproWeb, :router

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

  scope "/", AnyproWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/:slug", CoachController, :show
  end

  scope "/api", AnyproWeb do
    pipe_through :api

    post "/coaches", CoachController, :store
  end
end
