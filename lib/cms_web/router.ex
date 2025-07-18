defmodule CMSWeb.Router do
  use CMSWeb, :router

  import CMSWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CMSWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin_only_access do
    plug :require_authenticated_user
    plug :require_admin_user
  end

  scope "/", CMSWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", CMSWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:cms, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CMSWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", CMSWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_session,
      on_mount: [{CMSWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end
  end

  scope "/", CMSWeb do
    pipe_through [:browser, :admin_only_access]

    live_session :admin_required_live_session,
      on_mount: [
        {CMSWeb.UserAuth, :require_authenticated},
        {CMSWeb.UserAuth, :require_admin_access}
      ] do
      live "/admin/liturgies", LiturgyLive.Admin.Index, :index
      live "/admin/liturgies/new", LiturgyLive.Admin.Form, :new
      live "/admin/liturgies/:id/edit", LiturgyLive.Admin.Form, :edit

      live "/admin/users", UserLive.Admin.Index, :index
      live "/admin/users/new", UserLive.Admin.Form, :new
      live "/admin/users/:id/edit", UserLive.Admin.Form, :edit
    end
  end

  scope "/", CMSWeb do
    pipe_through [:browser]

    live_session :current_user_session,
      on_mount: [{CMSWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
      live "/liturgies/:id", LiturgyLive.Show, :show
      live "/songs", SongLive.Index, :index
      live "/songs/:id", SongLive.Show, :show
    end

    get "/users/lobby", UserOTPController, :lobby
    get "/liturgy", LiturgyController, :latest

    post "/users/log-in", UserSessionController, :create
    post "/users/verify-otp", UserOTPController, :verify_and_log_in
    delete "/users/log-out", UserSessionController, :delete
  end
end
