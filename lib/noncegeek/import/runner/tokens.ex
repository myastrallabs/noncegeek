defmodule Noncegeek.Import.Runner.Tokens do
  @moduledoc false

  # import Ecto.Query, only: [from: 2]

  alias Ecto.Multi

  alias Noncegeek.Import
  alias Noncegeek.Explorer.Model.Token

  @timeout 60_000

  def timeout, do: @timeout
  def option_key, do: :tokens
  def ecto_schema_module, do: Token

  def run(multi, changes_list, %{timestamps: timestamps} = options) do
    insert_options =
      options
      |> Map.get(option_key(), %{})
      |> Map.take(~w(on_conflict timeout)a)
      |> Map.put_new(:timeout, @timeout)
      |> Map.put(:timestamps, timestamps)

    multi
    |> Multi.run(:tokens, fn repo, _ ->
      insert(repo, changes_list, insert_options)
    end)
  end

  def insert(repo, changes_list, %{timeout: timeout, timestamps: timestamps} = _options)
      when is_list(changes_list) do
    {:ok, _} =
      Import.insert_changes_list(
        repo,
        changes_list,
        conflict_target: :token_id,
        on_conflict: :nothing,
        for: Token,
        returning: true,
        timeout: timeout,
        timestamps: timestamps
      )
  end
end
