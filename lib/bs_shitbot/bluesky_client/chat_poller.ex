defmodule BsShitbot.BlueskyClient.ChatPoller do
  use GenServer
  require Logger
  alias BsShitbot.JWTS

  # Poll every 1 second
  @poll_interval :timer.seconds(5)
  @endpoint "/xrpc/chat.bsky.convo.getLog"

  # Start the GenServer, accepting an initial cursor as an argument
  def start_link(initial_cursor) do
    GenServer.start_link(__MODULE__, %{cursor: initial_cursor, seen_events: MapSet.new()},
      name: __MODULE__
    )
  end

  # Initialize the GenServer with the provided cursor
  def init(state) do
    Logger.info("ChatPoller started with cursor: #{inspect(state[:cursor])}")
    schedule_poll()
    {:ok, %{state | cursor: ""}}
  end

  # Handle the periodic poll
  def handle_info(:poll, state) do
    case fetch_chat_messages(state[:cursor]) do
      {:ok, %{messages: messages, new_cursor: new_cursor}} ->
        handle_new_messages(messages, state)
        schedule_poll()
        {:noreply, %{state | cursor: new_cursor}}

      response ->
        Logger.error("Failed to fetch chat messages: #{inspect(response)}")
        schedule_poll()
        {:noreply, state}
    end
  end

  # Fetch chat messages from the endpoint
  defp fetch_chat_messages(cursor) do
    email = BsShitbot.config([:blue_sky, :email])
    pass = BsShitbot.config([:blue_sky, :pass])

    %{access_jwt: access_jwt, service_endpoint: service_endpoint} =
      JWTS.authenticate_with_email(email, pass)

    headers = [
      {"Authorization", "Bearer #{access_jwt}"},
      {"Atproto-Proxy", "did:web:api.bsky.chat#bsky_chat"}
    ]

    params = %{
      "cursor" => cursor
    }

    url = "#{service_endpoint}#{@endpoint}"

    case Req.get(url, headers: headers, params: params) do
      {:ok, %{status: 200, body: %{"logs" => messages, "cursor" => new_cursor}}} ->
        {:ok, %{messages: messages, new_cursor: new_cursor}}

      {:ok, %{status: status}} ->
        {:error, {:http_error, status}}

      {:error, reason} ->
        {:error, {:req_error, reason}}
    end
  end

  # Process the fetched chat messages and handle new ones
  defp handle_new_messages(messages, state) do
    Enum.each(messages, fn message ->
      event_id = message["id"]

      if not MapSet.member?(state[:seen_events], event_id) do
        Logger.info("New chat message: #{inspect(message)}")
        parse_message(message)
        # Add the new event ID to the seen set
        new_seen_events = MapSet.put(state[:seen_events], event_id)
        # Process the message (e.g., forward to another service, buffer, etc.)
        # Add your processing logic here.

        # Update state with the new seen events set
        {:ok, %{state | seen_events: new_seen_events}}
      end
    end)
  end

  # Schedule the next poll
  defp schedule_poll do
    Process.send_after(self(), :poll, @poll_interval)
  end

  def parse_message(%{"convoId" => convo_id, "message" => %{"text" => "/add @" <> username}}) do
    email = BsShitbot.config([:blue_sky, :email])
    pass = BsShitbot.config([:blue_sky, :pass])

    %{access_jwt: access_jwt, did: repo, service_endpoint: service_endpoint} =
      JWTS.authenticate_with_email(email, pass)

    {:ok, did} = BsShitbot.BlueskyClient.IdentResolver.resolve_did(username)

    case BsShitbot.BlueskyClient.IdentResolver.get_profiles([did]) do
      {:ok, %{"profiles" => profiles}} ->
        BsShitbot.BlueskyClient.Lists.mass_assign_users_to_list(
          profiles,
          access_jwt,
          repo,
          "at://did:plc:4nd2nxnptle7cdq3thxtsqe6/app.bsky.graph.list/3lfikbvo2n52b"
        )

        BsShitbot.BlueskyClient.Chat.send_message(
          access_jwt,
          service_endpoint,
          convo_id,
          "Adding 💩🤖 to the list!"
        )

        IO.inspect("sending to shitlist #{username}")

      {:error, reason} ->
        IO.inspect("Failed #{reason}")
    end
  end

  def parse_message(%{"convoId" => convo_id, "message" => %{"text" => "/remove @" <> username}}) do
    case BsShitbot.BlockedAccounts.get_blocked_account_by_handle(username) do
      %{uri: uri} ->
        email = BsShitbot.config([:blue_sky, :email])
        pass = BsShitbot.config([:blue_sky, :pass])

        %{access_jwt: access_jwt, did: repo, service_endpoint: service_endpoint} =
          JWTS.authenticate_with_email(email, pass)

        rkey = String.split(uri, "/") |> List.last()

        BsShitbot.BlueskyClient.Lists.mass_remove_users_from_list(
          [rkey],
          access_jwt,
          repo
        )

        BsShitbot.BlueskyClient.Chat.send_message(
          access_jwt,
          service_endpoint,
          convo_id,
          "Removing #{username} from the list!"
        )

        IO.inspect("removing from shitlist #{username}")
    end
  end

  def parse_message(%{"convoId" => convo_id, "message" => %{"text" => "/find @" <> username}}) do
    email = BsShitbot.config([:blue_sky, :email])
    pass = BsShitbot.config([:blue_sky, :pass])

    %{access_jwt: access_jwt, service_endpoint: service_endpoint} =
      JWTS.authenticate_with_email(email, pass)

    {:ok, did} = BsShitbot.BlueskyClient.IdentResolver.resolve_did(username)

    BsShitbot.BlueskyClient.Chat.send_message(
      access_jwt,
      service_endpoint,
      convo_id,
      "OK! Looking for #{did}"
    )

    message =
      case BsShitbot.BlueskyClient.Lists.find_rkey_for_did(
             access_jwt,
             did,
             "at://did:plc:4nd2nxnptle7cdq3thxtsqe6/app.bsky.graph.list/3lfikbvo2n52b"
           ) do
        %{"uri" => uri} -> uri
        message -> message
      end

    BsShitbot.BlueskyClient.Chat.send_message(
      access_jwt,
      service_endpoint,
      convo_id,
      message
    )
  end

  def parse_message(_) do
    IO.inspect("nope")
  end
end
