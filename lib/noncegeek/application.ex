defmodule Noncegeek.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Noncegeek.Repo,
      # Start the Telemetry supervisor
      NoncegeekWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Noncegeek.PubSub},
      # Start the Endpoint (http/https)
      NoncegeekWeb.Endpoint,
      {AptosEx, Application.fetch_env!(:noncegeek, AptosEx)}
      # Start a worker by calling: Noncegeek.Worker.start_link(arg)
      # {Noncegeek.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Noncegeek.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NoncegeekWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
