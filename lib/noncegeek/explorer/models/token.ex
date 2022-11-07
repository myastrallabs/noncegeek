defmodule Noncegeek.Explorer.Model.Token do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]
  schema "tokens" do
    # required
    field :token_id, :map
    field :collection_name, :string
    field :creator, :string
    field :name, :string

    # optional
    field :default_properties, :map
    field :description, :string
    field :largest_property_version, :decimal
    field :maximum, :decimal
    field :supply, :decimal
    field :mutability_config, :map
    field :royalty, :map
    field :uri, :string
    field :property_version, :integer

    timestamps()
  end

  @doc false
  def changeset(token, attrs) do
    required_fields = ~w(
      name
      creator
      collection_name
      property_version
      token_id
    )a

    optional_fields = ~w(
      maximum
      largest_property_version
      mutability_config
      description
      uri
      royalty
      supply
      default_properties
    )a

    token
    |> cast(attrs, required_fields ++ optional_fields)
    |> validate_required(required_fields)
  end

  def input_changeset(token, attrs) do
    required_fields = ~w(
      collection_name
      name
      description
      uri
    )a

    token
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
  end
end
