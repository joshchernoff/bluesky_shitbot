defmodule BsShitbot.BlockedAccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BsShitbot.BlockedAccounts` context.
  """

  @doc """
  Generate a blocked_account.
  """
  def blocked_account_fixture(attrs \\ %{}) do
    {:ok, blocked_account} =
      attrs
      |> Enum.into(%{
        avatar_uri: "some avatar_uri",
        did: "some did",
        followers_count: 42,
        following_count: 42,
        handle: "some handle",
        posts_count: 42,
        rkey: "some rkey"
      })
      |> BsShitbot.BlockedAccounts.create_blocked_account()

    blocked_account
  end
end
