defmodule Noncegeek.Explorer.Model.Event do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]
  schema "events" do
    field :sequence_number, :integer
    field :type, :string

    field :account_address, :string

    field :creation_number, :integer
    field :version, :integer

    # field :token_id, :map
    # field :collection_id, :map
    field :amount, :decimal
    field :data, :map

    belongs_to :token, Lotus.Explorer.Model.Token,
      foreign_key: :token_id,
      references: :token_id,
      type: :map

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    required_fields = ~w(
      account_address
      sequence_number
      token_id
      type
      data
      version
    )a

    optional_fields = ~w(amount)a

    event
    |> cast(attrs, required_fields ++ optional_fields)
    |> validate_required(required_fields)
  end
end
