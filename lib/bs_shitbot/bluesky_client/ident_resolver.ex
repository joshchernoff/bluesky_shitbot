defmodule BsShitbot.BlueskyClient.IdentResolver do
  @moduledoc """
  A module to resolve identities based on DIDs via a batch request.

  Example endpoint:
  https://public.api.bsky.app/xrpc/app.bsky.actor.getProfiles?actors[]=did1&actors[]=did2
  """

  @api_base "https://public.api.bsky.app/xrpc"

  @doc """
  Fetches profiles for a list of DIDs.

  ## Example
      iex> get_profiles(["did:example:123", "did:example:456"])
      {:ok, [%{"did" => "did:example:123", "profile" => ...}, %{"did" => "did:example:456", "profile" => ...}]}
  """
  def get_profiles(dids) when is_list(dids) do
    url = "#{@api_base}/app.bsky.actor.getProfiles"
    query = build_query(dids)

    case Req.get(url <> query) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      # parsed = IO.inspect(body)

      # case parsed do
      #   {:ok, %{"profiles" => profiles}} -> {:ok, profiles}
      #   {:error, reason} -> {:error, {:json_decode_error, reason}}
      # end

      {:ok, %{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      {:error, reason} ->
        {:error, {:request_failed, reason}}
    end
  end

  defp build_query(dids) do
    # Construct the query string by encoding each DID as `actors[]`
    query_string =
      dids
      |> Enum.map(&"actors[]=#{URI.encode(&1)}")
      |> Enum.join("&")

    "?#{query_string}"
  end
end
