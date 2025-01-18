defmodule BsShitbot.JWTS.JWT do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "jwts" do
    field :did, :string
    field :handle, :string
    field :email, :string
    field :access_jwt, :string
    field :refresh_jwt, :string
    field :service_endpoint, :string
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(jwt, attrs) do
    jwt
    |> cast(attrs, [:did, :handle, :email, :access_jwt, :refresh_jwt, :service_endpoint])
    |> validate_required([:did, :handle, :email, :access_jwt, :refresh_jwt, :service_endpoint])
  end
end
