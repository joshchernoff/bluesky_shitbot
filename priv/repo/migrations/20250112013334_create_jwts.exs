defmodule BsShitbot.Repo.Migrations.CreateJwts do
  use Ecto.Migration

  def change do
    create table(:jwts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :handle, :string
      add :email, :string
      add :access_jwt, :string
      add :refresh_jwt, :string

      timestamps(type: :utc_datetime)
    end
  end
end
