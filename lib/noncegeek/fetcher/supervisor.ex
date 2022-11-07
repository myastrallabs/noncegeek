defmodule Noncegeek.Fetcher.Supervisor do
  @moduledoc """
  Supervisor of all indexer worker supervision trees
  """

  use Supervisor

  require Logger

  alias Noncegeek.Fetcher

  def start_link(arguments, gen_server_options \\ []) do
    Supervisor.start_link(
      __MODULE__,
      arguments,
      Keyword.put_new(gen_server_options, :name, __MODULE__)
    )
  end

  @impl true
  def init(_arg) do
    Logger.info("Noncegeek.Fetcher.Supervisor Stared")
    # FIXME support multi-chain client

    basic_fetchers = [
      {Fetcher.EventHandle.Supervisor, [nil, [name: Fetcher.EventHandle.Supervisor]]}
    ]

    Supervisor.init(
      basic_fetchers,
      strategy: :one_for_one
    )
  end
end
