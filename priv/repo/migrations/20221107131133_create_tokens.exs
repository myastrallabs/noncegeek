defmodule Noncegeek.Repo.Migrations.CreateTokens do
  use Ecto.Migration

  def change do
    create table(:tokens) do
      add :collection_name, :string
      add :creator, :string
      add :name, :string

      add :property_version, :integer

      add :description, :text
      add :uri, :string

      add :default_properties, :map
      add :largest_property_version, :decimal
      add :mutability_config, :map
      add :royalty, :map
      add :maximum, :decimal
      add :supply, :decimal

      add :token_id, :map
      timestamps()
    end

    create unique_index(:tokens, [:token_id])
    create unique_index(:tokens, [:name, :collection_name, :creator])
  end
end
