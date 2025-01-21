defmodule BsShitbot.IdentUpdatePipeline do
  use Broadway
  require Logger

  alias Broadway.Message
  alias BsShitbot.IdentProducer
  alias BsShitbot.BlueskyClient.IdentResolver

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {IdentProducer, []},
        transformer: {__MODULE__, :transform, []},
        concurrency: 1
      ],
      processors: [
        default: [
          concurrency: 1
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
  def handle_message(:default, %{data: data} = message, _) do
    dids = Enum.map(data, fn [did, _] -> did end)

    case IdentResolver.get_profiles(dids) do
      {:ok, %{"profiles" => profiles}} ->
        Logger.info("Successfully queried profiles for dids #{data}")

        profiles
        |> Enum.each(fn profile ->
          [_, uri] = Enum.find(data, fn [did, _uri] -> did == profile["did"] end)
          parse_profile(profile, uri) |> BsShitbot.BlockedAccounts.upsert!()
        end)

        Message.ack_immediately(message)

      {:error, reason} ->
        Logger.error("Failed to query dids for #{data}: #{inspect(reason)}")
        Message.failed(message, reason)
    end
  end

  defp parse_profile(profile, uri) do
    dbg(profile)

    %{
      did: profile["did"],
      uri: uri,
      handle: Map.get(profile, "handle", nil),
      display_name: Map.get(profile, "displayName", nil),
      avatar_uri: Map.get(profile, "avatar", nil),
      posts_count: Map.get(profile, "postsCount", nil),
      following_count: Map.get(profile, "followsCount", nil),
      followers_count: Map.get(profile, "followersCount", nil),
      description: Map.get(profile, "description", nil),
      banner: Map.get(profile, "banner", nil),
      account_created_on: Map.get(profile, "createdAt", nil)
    }
  end
end
