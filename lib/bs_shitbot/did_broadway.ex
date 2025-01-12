defmodule BsShitbot.DidBroadway do
  use Broadway
  require Logger

  alias Broadway.Message
  alias BsShitbot.DidProducer
  alias BsShitbot.BlueskyClient.IdentResolver

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {DidProducer, []},
        transformer: {__MODULE__, :transform, []},
        concurrency: 1
      ],
      processors: [
        default: [
          concurrency: 5
        ]
      ],
      batchers: [
        default: [
          concurrency: 5
        ],
        insert_all: [
          batch_size: 100,
          batch_timeout: 1_000
        ]
      ]
    )
  end

  def transform(event, _options) do
    %Broadway.Message{
      data: event,
      acknowledger: {__MODULE__, :dids, []}
    }
  end

  def ack(:dids, _successful, _failed) do
    :ok
  end

  @impl true
  def handle_message(:default, %{data: dids} = message, _) do
    # did = message.data
    case IdentResolver.get_profiles(dids) do
      {:ok, profiles} ->
        # Logger.info("Successfully queried profiles for dids #{dids}")
        Message.update_data(message, fn _ -> profiles end)

      {:error, reason} ->
        Logger.error("Failed to query dids for #{dids}: #{inspect(reason)}")
        Message.failed(message, reason)
    end
  end

  @impl true
  def handle_batch(:default, messages, _batch_info, _context) do
    email = BsShitbot.config([:blue_sky, :email])
    pass = BsShitbot.config([:blue_sky, :pass])
    %{access_jwt: access_jwt, did: did} = BsShitbot.JWTS.authenticate_with_email(email, pass)

    messages
    |> Enum.map(fn m -> m.data end)
    |> List.flatten()
    |> Flow.from_enumerable()
    |> Flow.flat_map(fn %{"profiles" => profiles} -> profiles end)
    |> Flow.filter(fn profile ->
      profile["followsCount"] > 1000 and
        profile["postsCount"] < 10 and
        profile["followersCount"] < 10
    end)
    |> Flow.partition()
    |> Flow.map(fn %{
                     "did" => did,
                     "followsCount" => followsCount,
                     "postsCount" => postsCount,
                     "followersCount" => followersCount
                   } ->
      did
    end)
    |> Enum.to_list()
    |> BsShitbot.BlueskyClient.Lists.mass_assign_users_to_list(
      access_jwt,
      did,
      "at://did:plc:4nd2nxnptle7cdq3thxtsqe6/app.bsky.graph.list/3lfikbvo2n52b"
    )

    # .Repo.insert_all(SOMETHING, batch_data)
    messages
  end
end
