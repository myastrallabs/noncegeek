defmodule AptosEx do
  @moduledoc """
  The AptosEx module is a wrapper around the Aptos API.
  """

  use GenServer

  alias AptosEx.RPC

  defmodule State do
    defstruct ~w(
      rpc_endpoint
      client
    )a
  end

  def start_link(options) do
    rpc_endpoint = Keyword.get(options, :rpc_endpoint)

    unless rpc_endpoint do
      raise ArgumentError,
            ":rpc_endpoint must be provided to `#{__MODULE__}`" <>
              "to allow for json_rpc calls when running"
    end

    GenServer.start_link(__MODULE__, rpc_endpoint, name: __MODULE__)
  end

  @doc """
  Get Aptos client
  """
  def get_aptos_client() do
    with {:ok, client} <- GenServer.call(__MODULE__, :client) do
      client
    else
      _ ->
        raise RuntimeError, "connect aptos rpc failed, please check your config"
    end
  end

  @impl GenServer
  def init(rpc_endpoint) do
    state = %State{
      rpc_endpoint: rpc_endpoint
    }

    {:ok, state, {:continue, :start}}
  end

  @impl GenServer
  def handle_continue(:start, %State{rpc_endpoint: rpc_endpoint} = state) do
    client = RPC.connect(rpc_endpoint)
    {:noreply, %{state | client: client}}
  end

  @impl GenServer
  def handle_call(:client, _, %{client: client} = state) do
    {:reply, client, state}
  end

  @doc """
  Get Aptos account
  """
  def get_account(address) do
    client = get_aptos_client()
    RPC.get_account(client, address)
  end

  @doc """
  Get account resources
  """
  def get_account_resources(address, query \\ []) do
    client = get_aptos_client()
    RPC.get_account_resources(client, address, query)
  end

  @doc """
  Get account resource
  """
  def get_account_resource(address, resource_type, query \\ []) do
    client = get_aptos_client()
    RPC.get_account_resource(client, address, resource_type, query)
  end

  @doc """
  Get transaction by hash.
  """
  def get_transaction_by_hash(hash) do
    client = get_aptos_client()
    RPC.get_transaction_by_hash(client, hash)
  end

  @doc """
  Check transaction result.
  """
  def check_transaction_by_hash(hash, times \\ 3) do
    client = get_aptos_client()
    RPC.check_transaction_by_hash(client, hash, times)
  end

  @doc """
  Get events by event_key
  """
  def get_events(event_key) do
    client = get_aptos_client()
    RPC.get_events(client, event_key)
  end

  @doc """
  Get events by address event_handle
  """
  def get_events(address, event_handle, field, query \\ [limit: 10]) do
    client = get_aptos_client()
    RPC.get_events(client, address, event_handle, field, query)
  end

  @doc """
  Get table item
  """
  def get_table_item(table_handle, table_key) do
    client = get_aptos_client()
    RPC.get_table_item(client, table_handle, table_key)
  end

  @doc """
  Get token detail

  ## Examples

    iex> AptosEx.get_token_data("0xe19430a2498ff6800666d41cfd4b64d6d2a53574ef7457f700f96f4a61703d07", "DummyNames", "dummy1")

  """
  def get_token_data(creator, collection_name, token_name) do
    client = get_aptos_client()
    RPC.get_token_data(client, creator, collection_name, token_name)
  end

  @doc """
  Get collection data

  ## Examples

    iex> AptosEx.get_collection_data("0xe19430a2498ff6800666d41cfd4b64d6d2a53574ef7457f700f96f4a61703d07", "DummyNames")

  """
  def get_collection_data(account, collection_name) do
    client = get_aptos_client()
    RPC.get_collection_data(client, account, collection_name)
  end
end
