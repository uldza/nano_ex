defmodule NanoWeb.Router do
  use NanoWeb, :router

  import NanoWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {NanoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  scope "/", NanoWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/elements", PageController, :elements
    get "/subscribe", PageController, :subscribe
    get "/subscribe/success", PageController, :success
    get "/subscribe/checkout/:plan", PageController, :checkout
    post "/stripe/webhook", StripeWebhookController, :webhook

    # Newsletter subscription routes
    get "/subscription", PageController, :subscription_page
    post "/subscription", PageController, :handle_subscription

    # User authentication routes
    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end

  ## Authentication routes
  scope "/", NanoWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", NanoWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/rooms", NanoWeb do
    pipe_through [:browser, :require_authenticated_user, :require_active_subscription]

    get "/", PlayerController, :index
    get "/:room_id", PlayerController, :show
  end

  # Admin routes
  scope "/admin", NanoWeb do
    pipe_through [:browser, :require_admin_or_mod]

    get "/", AdminController, :dashboard

    get "/rooms/new", AdminController, :new_room
    post "/rooms", AdminController, :create_room
    get "/rooms/:room_id", AdminController, :room_management
    put "/rooms/:room_id", AdminController, :update_room
    post "/rooms/:room_id/questions", AdminController, :create_question
    put "/rooms/:room_id/questions/:question_id", AdminController, :update_question
    delete "/rooms/:room_id/questions/:question_id", AdminController, :delete_question

    post "/rooms/:room_id/questions/:question_id/activate",
         AdminController,
         :activate_question

    post "/rooms/:room_id/questions/:question_id/deactivate",
         AdminController,
         :deactivate_question

    post "/users/:id/make-admin", AdminController, :make_admin
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:nano, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: NanoWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
