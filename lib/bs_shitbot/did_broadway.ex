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
        Logger.info("Successfully queried profiles for dids #{dids}")
        Message.update_data(message, fn _ -> profiles end)

      {:error, reason} ->
        Logger.error("Failed to query dids for #{dids}: #{inspect(reason)}")
        Message.failed(message, reason)
    end
  end

  @impl true
  def handle_batch(:default, messages, _batch_info, _context) do
    batch_data =
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
        %{
          "did" => did,
          followsCount: followsCount,
          postsCount: postsCount,
          followersCount: followersCount
        }
      end)
      |> Enum.chunk_every(200)
      |> IO.inspect()

    # .Repo.insert_all(SOMETHING, batch_data)
    messages
  end
end
