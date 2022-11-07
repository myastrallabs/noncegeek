defmodule Noncegeek.Explorer do
  @moduledoc """
  The Explorer context.
  """
  import Ecto.Query, warn: false

  require Integer

  alias AptosEx

  alias Noncegeek.Fetcher
  alias Noncegeek.Explorer.Model.{Token, Event}
  alias Noncegeek.{Repo, Turbo}

  @doc """
  Paged tokens
  """
  def paged_tokens() do
    Turbo.all(Token)
  end

  @doc """
  Get single token
  """
  def get_token(clauses) when is_list(clauses) or is_map(clauses),
    do: Turbo.get_by(Token, clauses)

  def get_token(clauses) when is_integer(clauses), do: Turbo.get(Token, clauses)

  @doc """
  fetch token data && store

  ## Exmaples

    iex> Noncegeek.Explorer.fetch_token_data("0xe19430a2498ff6800666d41cfd4b64d6d2a53574ef7457f700f96f4a61703d07", "DummyNames", "dummy1")

  """
  def fetch_token_data(creator, collection_name, token_name) do
    with {:ok, token} <-
           get_token(%{creator: creator, name: token_name, collection_name: collection_name}),
         {:ok, data} <- AptosEx.get_token_data(creator, collection_name, token_name) do
      Turbo.update(token, data)
    end
  end

  def get_account_events(account, type) do
    sequence_number = get_sequence_number(account, type)

    case type do
      "0x3::token::DepositEvent" ->
        Fetcher.get_deposit_events(account, sequence_number)

      "0x3::token::WithdrawEvent" ->
        Fetcher.get_withdraw_events(account, sequence_number)
    end
  end

  def get_sequence_number(account, type) do
    from(e in Event,
      where: e.type == ^type,
      where: e.account_address == ^account,
      order_by: [desc: e.sequence_number],
      select: e.sequence_number,
      limit: 1
    )
    |> Repo.one()
    |> case do
      nil -> 0
      value -> value + 1
    end
  end

  @doc """
  fetch account events

  iex> Noncegeek.Explorer.refresh_account_events("0xe19430a2498ff6800666d41cfd4b64d6d2a53574ef7457f700f96f4a61703d07")
  iex> Noncegeek.Explorer.refresh_account_events("e698622471b41a92e13ae893ae4ff88b20c528f6da2bedcb24d74646bf972dc3")

  """
  def refresh_account_events(account) do
    get_account_events(account, "0x3::token::DepositEvent")
    get_account_events(account, "0x3::token::WithdrawEvent")

    list_account_tokens(account)
  end

  @doc """
  list account tokens
  ## TODO

  - [ ] user_tokens

  """
  def list_account_tokens(account) do
    from(e in Event,
      where:
        e.account_address == ^account and
          e.type in ["0x3::token::DepositEvent", "0x3::token::WithdrawEvent"],
      order_by: [desc: e.version],
      preload: [:token]
    )
    |> Repo.all()
    |> case do
      [] ->
        []

      value ->
        value
        |> Enum.group_by(& &1.token_id)
        |> Enum.map(fn {_token_id, token_events} ->
          case token_events |> length() |> Integer.is_even() do
            true ->
              nil

            false ->
              List.first(token_events)
          end
        end)
        |> Enum.reject(&is_nil/1)
        |> List.flatten()
    end
    |> then(&{:ok, &1})
  end
end
