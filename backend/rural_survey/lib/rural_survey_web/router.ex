defmodule RuralSurveyWeb.Router do
  use RuralSurveyWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug RuralSurveyWeb.Plugs.AuthPlug
  end

  scope "/api", RuralSurveyWeb do
    pipe_through :api

    post "/login", AuthController, :login
  end

  scope "/api", RuralSurveyWeb do
    pipe_through [:api, :auth]

    get "/me", UserController, :me

    # Survey routes
    get "/surveys", SurveyController, :index
    post "/surveys", SurveyController, :create
    get "/surveys/:id", SurveyController, :show
    put "/surveys/:id", SurveyController, :update

    # Village routes
    get "/villages", VillageController, :index

    # Admin routes
    get "/admin/dashboard/stats", AdminController, :dashboard_stats
    get "/admin/analytics", AdminController, :analytics
    get "/admin/surveys", AdminController, :all_surveys
    get "/admin/surveys/export", AdminController, :export_surveys
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:rural_survey, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: RuralSurveyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
