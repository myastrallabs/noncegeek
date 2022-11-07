defmodule Noncegeek.Explorer.Job.FetchTokenData do
  @moduledoc false

  require Logger

  use Oban.Worker, queue: :default, priority: 1, max_attempts: 20

  alias Noncegeek.Explorer

  @contract_creator Application.get_env(:noncegeek, :contract_creator)
  @collection_name Application.get_env(:noncegeek, :collection_name)

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"token_id" => token_id} = _args}) do
    %{"token_data_id" => %{"creator" => creator, "collection" => collection_name, "name" => name}} = token_id

    with {:ok, token} <- Explorer.fetch_token_data(creator, collection_name, name) do
      IO.inspect(token, label: "token")
      create_nft_image(token)
      :ok
    else
      _ ->
        {:error, :retry_fetcher_token_data}
    end
  end

  defp create_nft_image(%{collection_name: unquote(@collection_name), creator: unquote(@contract_creator), name: name} = _token) do
    IO.inspect("aaaaaaaaaaaaaaaaaaaaaaaaaaaaa")

    unique_num =
      name
      |> String.split(":")
      |> List.last()
      |> String.trim()

    file_path = "priv/static/images/#{unique_num}.jpg"

    if !File.exists?(file_path) do
      {:ok, %{body: body}} = Faker.Avatar.image_url() |> Tesla.get()
      File.write!(file_path, body)
    end
  end

  defp create_nft_image(_), do: nil
end
