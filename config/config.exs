# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :noncegeek,
  ecto_repos: [Noncegeek.Repo]

# Configures the endpoint
config :noncegeek, NoncegeekWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: NoncegeekWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Noncegeek.PubSub,
  live_view: [signing_salt: "6DNfOjDN"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :noncegeek, Noncegeek.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args: ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :noncegeek, Oban,
  repo: Noncegeek.Repo,
  plugins: [{Oban.Plugins.Pruner, max_age: 3 * 24 * 60 * 60}],
  queues: [default: 10]

config :noncegeek, AptosEx, rpc_endpoint: "https://testnet.aptoslabs.com/v1"

config :noncegeek,
  contract_address: "0xe698622471b41a92e13ae893ae4ff88b20c528f6da2bedcb24d74646bf972dc3",
  contract_creator: "0xe10e40298c16778e71a03fa7e00e7d29e12a77b5e1797b799034551401cc0cc4",
  collection_name: "NonceGeek Leaf"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
