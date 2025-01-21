defmodule BsShitbot.BlockedAccounts.BlockedAccount do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "blocked_accounts" do
    field :handle, :string
    field :display_name, :string
    field :did, :string
    field :uri, :string
    field :posts_count, :integer
    field :following_count, :integer
    field :followers_count, :integer
    field :avatar_uri, :string
    field :banner, :string
    field :description, :string
    field :account_created_on, :utc_datetime

    field :state, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(blocked_account, attrs) do
    blocked_account
    |> cast(attrs, [
      :handle,
      :did,
      :uri,
      :posts_count,
      :following_count,
      :followers_count,
      :avatar_uri,
      :display_name,
      :banner,
      :description,
      :account_created_on
    ])
    |> validate_required([
      :did,
      :uri
    ])
    |> unique_constraint(:did)
    |> unique_constraint(:uri)
  end
end
