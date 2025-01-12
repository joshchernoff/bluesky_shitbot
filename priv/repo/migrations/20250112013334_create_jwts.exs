defmodule BsShitbot.Repo.Migrations.CreateJwts do
  use Ecto.Migration

  def change do
    create table(:jwts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :did, :string
      add :handle, :string
      add :email, :string
      add :access_jwt, :text
      add :refresh_jwt, :text

      timestamps(type: :utc_datetime)
    end
  end
end
