defmodule BsShitbot.JWTS.JWT do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "jwts" do
    field :handle, :string
    field :email, :string
    field :access_jwt, :string
    field :refresh_jwt, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(jwt, attrs) do
    jwt
    |> cast(attrs, [:handle, :email, :access_jwt, :refresh_jwt])
    |> validate_required([:handle, :email, :access_jwt, :refresh_jwt])
  end
end
