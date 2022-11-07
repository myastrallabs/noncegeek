defmodule Noncegeek.Fetcher do
  @moduledoc false

  alias AptosEx

  alias Noncegeek.Fetcher.Transform
  alias Noncegeek.{Explorer, Import}

  defmodule TaskData do
    @moduledoc """
    %Task{} with state && result && contract_name
    """
    defstruct event_handle: nil,
              account: nil,
              field: nil,
              type: nil,
              sequence_number: 0,
              ref: nil

    # def event_handle_id(%__MODULE__{event_handle: event_handle, field: field}), do: event_handle <> "::" <> field
    def event_type(%__MODULE__{type: type}), do: type
  end

  @doc """
  iex> Noncegeek.Fetcher.task(%{sequence_number: 0, account: "0xe698622471b41a92e13ae893ae4ff88b20c528f6da2bedcb24d74646bf972dc3", event_handle: "0xe698622471b41a92e13ae893ae4ff88b20c528f6da2bedcb24d74646bf972dc3::LEAF::MintData", field: "mint_events"})

  """
  def task(%{sequence_number: sequence_number} = task_data) do
    case fetch_and_import_events(task_data) do
      {:ok, %{events: events}} when events != [] ->
        events
        |> Enum.max_by(&Map.get(&1, :sequence_number))
        |> Map.get(:sequence_number)
        |> Kernel.+(1)

      {:ok, _} ->
        sequence_number

        # {:error, _} ->
        #   sequence_number
    end
  end

  @doc """
  Noncegeek.Fetcher.get_withdraw_events("0xe19430a2498ff6800666d41cfd4b64d6d2a53574ef7457f700f96f4a61703d07", 0)
  """
  def get_withdraw_events(account, sequence_number) do
    task_data = %TaskData{
      sequence_number: sequence_number,
      account: account,
      event_handle: "0x3::token::TokenStore",
      field: "withdraw_events"
    }

    task(task_data)
  end

  @doc """
  Noncegeek.Fetcher.get_deposit_events("0xe19430a2498ff6800666d41cfd4b64d6d2a53574ef7457f700f96f4a61703d07", 0)
  """
  def get_deposit_events(account, sequence_number) do
    task_data = %TaskData{
      sequence_number: sequence_number,
      account: account,
      event_handle: "0x3::token::TokenStore",
      field: "deposit_events"
    }

    task(task_data)
  end

  defp fetch_and_import_events(
         %{
           sequence_number: sequence_number,
           account: account,
           field: field,
           event_handle: event_handle
         } = _task_data
       ) do
    with {:ok, event_list} <-
           AptosEx.get_events(account, event_handle, field, start: sequence_number),
         {:ok, import_list} <- Transform.params_set(event_list) do
      {:ok, result} = Import.run(import_list)

      async_fetcher(result)

      {:ok, result}
    end
  end

  defp async_fetcher(%{tokens: tokens}) do
    tokens
    |> Enum.each(fn item ->
      %{token_id: item.token_id}
      |> Explorer.Job.FetchTokenData.new()
      |> Oban.insert()
    end)
  end

  defp async_fetcher(_), do: :ok
end
