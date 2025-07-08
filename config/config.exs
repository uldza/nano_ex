# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :iex, default_prompt: "nano|>"

config :nano,
  ecto_repos: [Nano.Repo],
  generators: [timestamp_type: :utc_datetime],
  mailer_default_from_name: "PIKABU",
  mailer_default_from_email: "no-reply@pikabu.lv",
  support_email: "pikabu@pikabu.lv",
  app_name: "PIKABU"

# Configures the endpoint
config :nano, NanoWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: NanoWeb.ErrorHTML, json: NanoWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Nano.PubSub,
  live_view: [signing_salt: "JNi/cA9g"]

# Configures the Kood endpoint
config :nano, KoodWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: KoodWeb.ErrorHTML, json: KoodWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Nano.PubSub,
  live_view: [signing_salt: "k00d_s1gnSa!t_#456"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :nano, Nano.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  nano: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  nano: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Subscription plans configuration
config :nano, :subscription_plan, %{
  id: :monthly,
  stripe_product_id: "prod_Sdr1lVjY5sDBhl",
  stripe_price_id: "price_1RiZJ7PIJpjvbKxcEIjcV348",
  price: 18,
  interval: "month",
  trial_days: 7
}

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
