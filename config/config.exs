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

config :tailwind,
  version: "3.2.1",
  default: [
    args: ~w(
    --config=tailwind.config.js
    --input=css/app.css
    --output=../priv/static/assets/app.css
  ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :noncegeek, Oban,
  repo: Noncegeek.Repo,
  plugins: [{Oban.Plugins.Pruner, max_age: 3 * 24 * 60 * 60}],
  queues: [default: 10]

config :noncegeek, AptosEx, rpc_endpoint: "https://testnet.aptoslabs.com/v1"

config :noncegeek,
  contract_address: "0x8444b675957431eea8ba816a2653bc5454427959fc0eecca55de814009b9be81",
  contract_creator: "0x75b12ae0fc6ee562a3dd0a153002152907c137eb9b9b514084d0897ea3fc9617",
  collection_name: "NonceGeek Leaf"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
