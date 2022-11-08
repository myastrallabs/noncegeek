defmodule Noncegeek.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :sequence_number, :integer
      add :type, :string

      add :version, :integer
      add :creation_number, :integer
      add :account_address, :string

      add :token_id, :map
      add :amount, :decimal
      add :data, :map

      timestamps()
    end

    create unique_index(:events, [:sequence_number, :type, :account_address])

    create index(:events, [:token_id])
    create index(:events, [:account_address])
  end
end
