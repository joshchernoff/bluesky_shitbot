defmodule BsShitbot.BlueskyClient.Lists do
  @moduledoc """
  Module to interact with Bluesky API for creating and managing user lists.
  """

  @base_url "https://bsky.social/xrpc"
  @list_collection "app.bsky.graph.list"
  @listitem_collection "app.bsky.graph.listitem"

  # Function to fetch all lists of a given DID
  def get_lists_by_did(token, did) do
    url = "#{@base_url}/app.bsky.graph.getLists"

    # Parameters to specify the DID
    params = %{
      "actor" => did
    }

    headers = [
      {"Authorization", "Bearer #{token}"}
    ]

    Req.get!(url, headers: headers, params: params)
    |> handle_response()
  end

  # Function to fetch detailed information about a specific list with optional cursor support
  def get_list(token, list_uri, cursor \\ nil) do
    url = "#{@base_url}/app.bsky.graph.getList"

    # Include the cursor in params only if it's provided
    params =
      %{
        "list" => list_uri
      }
      |> Map.merge(if cursor, do: %{"cursor" => cursor}, else: %{})

    headers = [
      {"Authorization", "Bearer #{token}"}
    ]

    Req.get!(url, headers: headers, params: params)
    |> handle_response()
  end

  # Function to create a new list
  def create_list(token, repo, name, description, purpose \\ "app.bsky.graph.defs#modlist") do
    url = "#{@base_url}/com.atproto.repo.createRecord"

    body = %{
      "repo" => repo,
      "collection" => @list_collection,
      "record" => %{
        "$type" => @list_collection,
        "purpose" => purpose,
        "name" => name,
        "description" => description,
        "createdAt" => DateTime.utc_now() |> DateTime.to_iso8601()
      }
    }

    headers = [{"Authorization", "Bearer #{token}"}]

    Req.post!(url, headers: headers, json: body)
    |> handle_response()
  end

  # Function to mass assign users to the list
  def mass_assign_users_to_list(profiles, token, repo, list_uri) do
    profiles
    |> Enum.map(&create_listitem(token, repo, list_uri, &1))
    |> handle_batch_response()
  end

  def mass_remove_users_from_list(rkeys, token, repo) do
    rkeys
    |> Enum.map(&delete_listitem(token, repo, &1))
    |> handle_batch_response()
  end

  def create_listitem(token, repo, list_uri, %{"did" => did} = profile) do
    case BsShitbot.Repo.get_by(BsShitbot.BlockedAccounts.BlockedAccount, %{did: did}) do
      nil ->
        url = "#{@base_url}/com.atproto.repo.createRecord"

        body =
          %{
            "repo" => repo,
            "collection" => @listitem_collection,
            "record" => %{
              "$type" => @listitem_collection,
              "subject" => profile["did"],
              "list" => list_uri,
              "createdAt" => DateTime.utc_now() |> DateTime.to_iso8601()
            }
          }

        headers = [{"Authorization", "Bearer #{token}"}]

        Task.async(fn ->
          case Req.post(url, headers: headers, json: body) do
            {:ok, %{status: 200, body: body}} ->
              {:ok, body, profile}

            {:ok, %{status: status, body: body}} ->
              {:error, {:http_error, status, body}}

            {:error, reason} ->
              # parse for bad actors and get the index from the error and return the did that failed.
              {:error, {:request_failed, reason}}
          end
        end)

      blocked_account ->
        Task.async(fn ->
          BsShitbot.BlockedAccounts.update_blocked_account(
            blocked_account,
            parse_profile(profile)
          )
        end)
    end
  end

  def delete_listitem(token, repo, rkey) do
    url = "#{@base_url}/com.atproto.repo.deleteRecord"

    body =
      %{
        "repo" => repo,
        "collection" => @listitem_collection,
        "rkey" => rkey
      }

    headers = [{"Authorization", "Bearer #{token}"}]

    Task.async(fn ->
      Req.post(url, headers: headers, json: body)
    end)
  end

  def find_rkey_for_did(token, did, list, cursor \\ nil, count \\ 0) do
    case BsShitbot.BlueskyClient.Lists.get_list(token, list, cursor) do
      {:ok, %{"items" => []}} ->
        "DID not found out of #{count} active accounts"

      {:ok, %{"cursor" => cursor, "items" => items}} ->
        case Enum.find(items, fn %{"subject" => %{"did" => i_did}} ->
               did == i_did
             end) do
          nil ->
            find_rkey_for_did(token, did, list, cursor, count + Enum.count(items))

          item ->
            item
        end
    end
  end

  # Handle batch response
  defp handle_batch_response(tasks) do
    tasks
    |> Enum.map(&Task.await/1)
    |> Enum.map(fn
      {:ok, body, profile} ->
        uri = Map.get(body, "uri", nil)
        profile = parse_profile(profile, uri)
        {:ok, block} = BsShitbot.BlockedAccounts.create_blocked_account(profile)

        Phoenix.PubSub.broadcast(BsShitbot.PubSub, "blocks", %{block | state: :new})

      {:ok, _profile} ->
        :ok

      %{status: status, body: body} ->
        {:error, %{status: status, body: body}}
    end)
  end

  # General response handler
  defp handle_response(%Req.Response{status: status, body: body}) when status in 200..299 do
    {:ok, body}
  end

  defp handle_response(%Req.Response{status: status, body: body}) do
    {:error, %{status: status, body: Jason.decode!(body)}}
  end

  defp parse_profile(profile, uri) do
    %{
      did: profile["did"],
      uri: uri,
      handle: Map.get(profile, "handle", nil),
      display_name: Map.get(profile, "displayName", nil),
      avatar_uri: Map.get(profile, "avatar", nil),
      posts_count: Map.get(profile, "postsCount", nil),
      following_count: Map.get(profile, "followsCount", nil),
      followers_count: Map.get(profile, "followersCount", nil)
    }
  end

  defp parse_profile(profile) do
    %{
      handle: Map.get(profile, "handle", nil),
      display_name: Map.get(profile, "displayName", nil),
      avatar_uri: Map.get(profile, "avatar", nil),
      posts_count: Map.get(profile, "postsCount", nil),
      following_count: Map.get(profile, "followsCount", nil),
      followers_count: Map.get(profile, "followersCount", nil)
    }
  end
end
