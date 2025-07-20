# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :cms, :scopes,
  user: [
    default: true,
    module: CMS.Accounts.Scope,
    assign_key: :current_scope,
    access_path: [:user, :id],
    schema_key: :user_id,
    schema_type: :id,
    schema_table: :users,
    test_data_fixture: CMS.AccountsFixtures,
    test_login_helper: :register_and_log_in_user
  ]

config :cms,
  namespace: CMS,
  ecto_repos: [CMS.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :cms, CMSWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: CMSWeb.ErrorHTML, json: CMSWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: CMS.PubSub,
  live_view: [signing_salt: "91mAmnWG"]

config :cms, CMSWeb.Gettext,
  default_locale: "pt",
  locales: ~w(pt en),
  ecto_translators: [Ecto.Changeset]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :cms, CMS.Mailer,
  adapter: Swoosh.Adapters.Local,
  default_sender_email: "guybrush@example.com",
  default_sender_name: "Guybrush Threepwood"

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  cms: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.0.9",
  cms: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
