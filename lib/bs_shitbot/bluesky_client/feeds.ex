defmodule BsShitbot.BlueskyClient.Feeds do
  @moduledoc """
  Module to interact with Bluesky API for creating, managing, and updating custom feeds.
  """

  @base_url "https://bsky.social/xrpc"
  @feed_generator_collection "app.bsky.feed.generator"

  @doc """
  Create a new feed generator.
  ## Parameters
  - `token` (string): The authorization token.
  - `repo` (string): The DID of the repository.
  - `name` (string): The name of the feed.
  - `display_name` (string): The display name for the feed.
  - `description` (string): A description of the feed.
  - `feed_uri` (string, optional): The URI of the feed logic.
  - `rules` (map, optional): Rules defining the logic of the feed (e.g., filters, sorting criteria).

  ## Returns
  - `{:ok, response_body}` on success.
  - `{:error, %{status: status, body: body}}` on failure.
  """
  def create_feed(
        token,
        repo,
        name,
        display_name,
        description,
        rules \\ %{}
      ) do
    url = "#{@base_url}/com.atproto.repo.createRecord"

    body = %{
      "repo" => repo,
      "collection" => @feed_generator_collection,
      "record" => %{
        "$type" => @feed_generator_collection,
        "did" => repo,
        "name" => name,
        "displayName" => display_name,
        "description" => description,
        "rules" => rules,
        "createdAt" => DateTime.utc_now() |> DateTime.to_iso8601()
      }
    }

    headers = [{"Authorization", "Bearer #{token}"}]

    Req.post!(url, headers: headers, json: body)
    |> handle_response()
  end

  @doc """
  Update the feed logic or rules.

  ## Parameters
  - `token` (string): The authorization token.
  - `repo` (string): The DID of the repository.
  - `rkey` (string): The record key of the feed generator.
  - `rules` (map): A map of new rules to update.
  - `feed_uri` (string): The new feed URI with updated logic or rules.

  ## Returns
  - `{:ok, response_body}` on success.
  - `{:error, %{status: status, body: body}}` on failure.
  """
  def update_feed_rules(token, repo, rkey, rules, feed_uri \\ nil) do
    url = "#{@base_url}/com.atproto.repo.putRecord"

    body = %{
      "repo" => repo,
      "collection" => @feed_generator_collection,
      "rkey" => rkey,
      "record" => %{
        "$type" => @feed_generator_collection,
        "rules" => rules,
        "feed" => feed_uri,
        "updatedAt" => DateTime.utc_now() |> DateTime.to_iso8601()
      }
    }

    headers = [{"Authorization", "Bearer #{token}"}]

    Req.post!(url, headers: headers, json: body)
    |> handle_response()
  end

  @doc """
  Update the feed logic or metadata.

  ## Parameters
  - `token` (string): The authorization token.
  - `repo` (string): The DID of the repository.
  - `rkey` (string): The record key of the feed generator.
  - `feed_uri` (string): The new feed URI with updated logic or rules.

  ## Returns
  - `{:ok, response_body}` on success.
  - `{:error, %{status: status, body: body}}` on failure.
  """
  def update_feed_logic(token, repo, rkey, feed_uri) do
    url = "#{@base_url}/com.atproto.repo.putRecord"

    body = %{
      "repo" => repo,
      "collection" => @feed_generator_collection,
      "rkey" => rkey,
      "record" => %{
        "$type" => @feed_generator_collection,
        "feed" => feed_uri,
        "updatedAt" => DateTime.utc_now() |> DateTime.to_iso8601()
      }
    }

    headers = [{"Authorization", "Bearer #{token}"}]

    Req.post!(url, headers: headers, json: body)
    |> handle_response()
  end

  @doc """
  Delete an existing feed generator.

  ## Parameters
  - `token` (string): The authorization token.
  - `repo` (string): The DID of the repository.
  - `rkey` (string): The record key of the feed generator to delete.

  ## Returns
  - `{:ok, response_body}` on success.
  - `{:error, %{status: status, body: body}}` on failure.
  """
  def delete_feed(token, repo, rkey) do
    url = "#{@base_url}/com.atproto.repo.deleteRecord"

    body = %{
      "repo" => repo,
      "collection" => @feed_generator_collection,
      "rkey" => rkey
    }

    headers = [{"Authorization", "Bearer #{token}"}]

    Req.post!(url, headers: headers, json: body)
    |> handle_response()
  end

  @doc """
  Fetch posts from a specific feed.

  ## Parameters
  - `token` (string): The authorization token.
  - `feed_uri` (string): The URI of the feed.
  - `cursor` (string, optional): Cursor for pagination.

  ## Returns
  - `{:ok, response_body}` on success.
  - `{:error, %{status: status, body: body}}` on failure.
  """
  def fetch_feed_posts(token, feed_uri, cursor \\ nil) do
    url = "#{@base_url}/app.bsky.feed.getFeed"

    params =
      %{"feed" => feed_uri}
      |> Map.merge(if cursor, do: %{"cursor" => cursor}, else: %{})

    headers = [
      {"Authorization", "Bearer #{token}"}
    ]

    Req.get!(url, headers: headers, params: params)
    |> handle_response()
  end

  defp handle_response(%Req.Response{status: status, body: body}) when status in 200..299 do
    {:ok, body}
  end

  defp handle_response(%Req.Response{status: status, body: body}) do
    {:error, %{status: status, body: Jason.decode!(body)}}
  end
end
