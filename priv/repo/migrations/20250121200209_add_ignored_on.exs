defmodule BsShitbot.Repo.Migrations.AddIgnoredOn do
  use Ecto.Migration

  def change do
    alter table(:blocked_accounts) do
      add :ignored_on, :utc_datetime
    end

    create index(:blocked_accounts, [:ignored_on])
  end
end
