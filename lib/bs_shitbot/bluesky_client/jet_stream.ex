defmodule BsShitbot.BlueskyClient.JetStream do
  use WebSockex
  require Logger
  alias BsShitbot.DidBuffer
  alias BsShitbot.JWTS

  def start_link(_) do
    url = "wss://jetstream1.us-west.bsky.network/subscribe?wantedCollections[]=app.bsky.feed.post"
    email = BsShitbot.config([:blue_sky, :email])
    pass = BsShitbot.config([:blue_sky, :pass])
    %{access_jwt: access_jwt} = JWTS.authenticate_with_email(email, pass)

    WebSockex.start_link(url, __MODULE__, %{
      access_token: access_jwt
    })
  end

  def init(state) do
    Logger.info("Successfully authenticated and connected.")
    {:ok, state}
  end

  @impl true
  def handle_connect(_conn, state) do
    Logger.info("Successfully connected to Bluesky JetStream.")
    {:ok, state}
  end

  @impl true
  def handle_frame({_type, msg}, state) do
    case Jason.decode(msg) do
      {:ok, parsed_msg} ->
        # Extract the DID from the parsed message
        parsed_msg
        |> is_follow?()

      # |> Map.get("did")
      # Send to producer of broadway to process profile

      {:error, reason} ->
        Logger.error("Failed to decode JSON: #{inspect(reason)}")
    end

    {:ok, state}
  end

  def is_follow?(%{
        "commit" => %{
          "collection" => "app.bsky.graph.follow",
          "operation" => "create"
        },
        "did" => did
      }) do
    DidBuffer.add_did(did)
  end

  def is_follow?(_), do: nil
end
