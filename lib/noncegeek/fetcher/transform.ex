defmodule Noncegeek.Fetcher.Transform do
  @moduledoc false

  def integerfy(id) when is_binary(id), do: String.to_integer(id)
  def integerfy(id), do: id

  def stringfy(v) when is_binary(v), do: v
  def stringfy(v) when is_integer(v), do: to_string(v)
  def stringfy(v) when is_atom(v), do: to_string(v)
  def stringfy(v), do: v

  def params_set(event_list) do
    event_params = event_params_set(event_list)
    token_params = token_params_set(event_list)

    {:ok,
     %{
       events: %{params: event_params},
       tokens: %{params: token_params}
     }}
  end

  def token_params_set(event_list) do
    event_list
    |> Enum.group_by(&get_token_id(&1))
    |> Enum.map(fn {token_id, _} ->
      %{
        token_id: token_id,
        property_version: token_id.property_version,
        collection_name: token_id.token_data_id.collection,
        creator: token_id.token_data_id.creator,
        name: token_id.token_data_id.name
      }
    end)
  end

  def event_params_set(event_list) do
    event_list
    |> Enum.map(&to_elixir/1)
    |> Enum.map(&event_to_params(&1))
  end

  defp to_elixir(event), do: Enum.into(event, %{}, &entry_to_elixir/1)

  defp entry_to_elixir({key, value}) when key in ~w(sequence_number version)a,
    do: {key, integerfy(value)}

  defp entry_to_elixir(entry), do: entry

  defp event_to_params(event_data) do
    %{
      sequence_number: event_data.sequence_number,
      creation_number: event_data.guid.creation_number,
      account_address: event_data.guid.account_address,
      data: event_data.data,
      token_id: get_token_id(event_data),
      version: event_data.version,
      type: event_data.type
    }
  end

  defp get_token_id(event_data),
    do: get_in(event_data, [:data, :id]) || get_in(event_data, [:data, :token_id])
end
