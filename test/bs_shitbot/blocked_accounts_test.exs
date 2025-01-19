defmodule BsShitbot.BlockedAccountsTest do
  use BsShitbot.DataCase

  alias BsShitbot.BlockedAccounts

  describe "blocked_accounts" do
    alias BsShitbot.BlockedAccounts.BlockedAccount

    import BsShitbot.BlockedAccountsFixtures

    @invalid_attrs %{handle: nil, did: nil, rkey: nil, posts_count: nil, following_count: nil, followers_count: nil, avatar_uri: nil}

    test "list_blocked_accounts/0 returns all blocked_accounts" do
      blocked_account = blocked_account_fixture()
      assert BlockedAccounts.list_blocked_accounts() == [blocked_account]
    end

    test "get_blocked_account!/1 returns the blocked_account with given id" do
      blocked_account = blocked_account_fixture()
      assert BlockedAccounts.get_blocked_account!(blocked_account.id) == blocked_account
    end

    test "create_blocked_account/1 with valid data creates a blocked_account" do
      valid_attrs = %{handle: "some handle", did: "some did", rkey: "some rkey", posts_count: 42, following_count: 42, followers_count: 42, avatar_uri: "some avatar_uri"}

      assert {:ok, %BlockedAccount{} = blocked_account} = BlockedAccounts.create_blocked_account(valid_attrs)
      assert blocked_account.handle == "some handle"
      assert blocked_account.did == "some did"
      assert blocked_account.rkey == "some rkey"
      assert blocked_account.posts_count == 42
      assert blocked_account.following_count == 42
      assert blocked_account.followers_count == 42
      assert blocked_account.avatar_uri == "some avatar_uri"
    end

    test "create_blocked_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BlockedAccounts.create_blocked_account(@invalid_attrs)
    end

    test "update_blocked_account/2 with valid data updates the blocked_account" do
      blocked_account = blocked_account_fixture()
      update_attrs = %{handle: "some updated handle", did: "some updated did", rkey: "some updated rkey", posts_count: 43, following_count: 43, followers_count: 43, avatar_uri: "some updated avatar_uri"}

      assert {:ok, %BlockedAccount{} = blocked_account} = BlockedAccounts.update_blocked_account(blocked_account, update_attrs)
      assert blocked_account.handle == "some updated handle"
      assert blocked_account.did == "some updated did"
      assert blocked_account.rkey == "some updated rkey"
      assert blocked_account.posts_count == 43
      assert blocked_account.following_count == 43
      assert blocked_account.followers_count == 43
      assert blocked_account.avatar_uri == "some updated avatar_uri"
    end

    test "update_blocked_account/2 with invalid data returns error changeset" do
      blocked_account = blocked_account_fixture()
      assert {:error, %Ecto.Changeset{}} = BlockedAccounts.update_blocked_account(blocked_account, @invalid_attrs)
      assert blocked_account == BlockedAccounts.get_blocked_account!(blocked_account.id)
    end

    test "delete_blocked_account/1 deletes the blocked_account" do
      blocked_account = blocked_account_fixture()
      assert {:ok, %BlockedAccount{}} = BlockedAccounts.delete_blocked_account(blocked_account)
      assert_raise Ecto.NoResultsError, fn -> BlockedAccounts.get_blocked_account!(blocked_account.id) end
    end

    test "change_blocked_account/1 returns a blocked_account changeset" do
      blocked_account = blocked_account_fixture()
      assert %Ecto.Changeset{} = BlockedAccounts.change_blocked_account(blocked_account)
    end
  end
end
