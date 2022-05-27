defmodule HVSWeb.Router do
  use HVSWeb, :router

  alias HVSWeb.Plugs

  pipeline :api do
    plug :accepts, ["json"]
    plug Plugs.Authz, :api
  end

  scope "/api", HVSWeb do
    pipe_through :api

    get "/check", APIController, :check_access

    resources "/users", UserController, only: [:create, :show, :index]
    resources "/visits", VisitController, only: [:create, :show, :index]

    post "/users/:user_id/request", VisitController, :request
    post "/visits/:visit_id/fulfill", VisitController, :fulfill
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: HVSWeb.Telemetry
    end
  end
end
