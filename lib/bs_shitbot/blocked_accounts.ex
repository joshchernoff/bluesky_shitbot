defmodule BsShitbot.BlockedAccounts do
  @moduledoc """
  The BlockedAccounts context.
  """

  import Ecto.Query, warn: false
  alias BsShitbot.Repo

  alias BsShitbot.BlockedAccounts.BlockedAccount

  def last_20_blocked_accounts do
    from(b in BlockedAccount, order_by: [desc: b.inserted_at], limit: 20)
    |> Repo.all()
  end

  @doc """
  Returns the list of blocked_accounts.

  ## Examples

      iex> list_blocked_accounts()
      [%BlockedAccount{}, ...]

  """
  def list_blocked_accounts do
    Repo.all(BlockedAccount)
  end

  @doc """
  Gets a single blocked_account.

  Raises `Ecto.NoResultsError` if the Blocked account does not exist.

  ## Examples

      iex> get_blocked_account!(123)
      %BlockedAccount{}

      iex> get_blocked_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_blocked_account!(id), do: Repo.get!(BlockedAccount, id)

  def get_blocked_account_by_handle(handle), do: Repo.get_by!(BlockedAccount, %{handle: handle})

  def upsert!(%{did: did, uri: uri} = blocked_record) do
    handle = Map.get(blocked_record, :handle, nil)
    display_name = Map.get(blocked_record, :display_name, nil)
    avatar_uri = Map.get(blocked_record, :avatar_uri, nil)
    posts_count = Map.get(blocked_record, :posts_count, nil)
    following_count = Map.get(blocked_record, :following_count, nil)
    followers_count = Map.get(blocked_record, :followers_count, nil)

    query =
      from(d in BsShitbot.BlockedAccounts.BlockedAccount,
        update: [
          set: [
            uri: ^uri,
            handle: ^handle,
            avatar_uri: ^avatar_uri,
            display_name: ^display_name,
            posts_count: ^posts_count,
            following_count: ^following_count,
            followers_count: ^followers_count
          ]
        ]
      )

    BsShitbot.Repo.insert!(
      %BsShitbot.BlockedAccounts.BlockedAccount{
        did: did,
        uri: uri,
        handle: handle,
        display_name: display_name,
        avatar_uri: avatar_uri,
        posts_count: posts_count,
        following_count: following_count,
        followers_count: followers_count
      },
      on_conflict: query,
      conflict_target: [:did]
    )
  end

  @doc """
  Creates a blocked_account.

  ## Examples

      iex> create_blocked_account(%{field: value})
      {:ok, %BlockedAccount{}}

      iex> create_blocked_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_blocked_account(attrs \\ %{}) do
    %BlockedAccount{}
    |> BlockedAccount.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a blocked_account.

  ## Examples

      iex> update_blocked_account(blocked_account, %{field: new_value})
      {:ok, %BlockedAccount{}}

      iex> update_blocked_account(blocked_account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_blocked_account(%BlockedAccount{} = blocked_account, attrs) do
    blocked_account
    |> BlockedAccount.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a blocked_account.

  ## Examples

      iex> delete_blocked_account(blocked_account)
      {:ok, %BlockedAccount{}}

      iex> delete_blocked_account(blocked_account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_blocked_account(%BlockedAccount{} = blocked_account) do
    Repo.delete(blocked_account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking blocked_account changes.

  ## Examples

      iex> change_blocked_account(blocked_account)
      %Ecto.Changeset{data: %BlockedAccount{}}

  """
  def change_blocked_account(%BlockedAccount{} = blocked_account, attrs \\ %{}) do
    BlockedAccount.changeset(blocked_account, attrs)
  end
end
