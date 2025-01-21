defmodule BsShitbot.Repo.Migrations.CreateBlockedAccounts do
  use Ecto.Migration

  def change do
    create table(:blocked_accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :uri, :text
      add :did, :text
      add :handle, :text
      add :display_name, :text
      add :posts_count, :integer
      add :following_count, :integer
      add :followers_count, :integer
      add :avatar_uri, :text
      add :description, :text
      add :banner, :text
      add :account_created_on, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:blocked_accounts, [:handle])
    create unique_index(:blocked_accounts, [:did])
    create unique_index(:blocked_accounts, [:uri])
  end
end
