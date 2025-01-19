defmodule BsShitbot.IdendInsertPipeline do
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
          concurrency: 1
        ]
      ],
      batchers: [
        default: [
          concurrency: 1
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
  def handle_message(:default, message, _) do
    case IdentResolver.get_profiles(message.data) do
      {:ok, profiles} ->
        Message.update_data(message, fn _ -> profiles end)

      {:error, reason} ->
        Message.failed(message, reason)
    end
  end

  # def handle_message(:default, %{data: data} = message, _) do
  #   email = BsShitbot.config([:blue_sky, :email])
  #   pass = BsShitbot.config([:blue_sky, :pass])
  #   %{did: my_did, access_jwt: access_jwt} = BsShitbot.JWTS.authenticate_with_email(email, pass)

  #   data
  #   |> Enum.filter(fn profile ->
  #     # IO.inspect([profile, above_threshold?(profile)])
  #     !above_threshold?(profile)
  #   end)
  #   |> Enum.map(fn %{uri: uri} -> String.split(uri, "/") |> List.last() end)
  #   |> IO.inspect()
  #   |> BsShitbot.BlueskyClient.Lists.mass_remove_users_from_list(
  #     access_jwt,
  #     my_did
  #   )

  #   Message.ack_immediately(message)
  # end

  @impl true
  def handle_batch(:default, messages, _batch_info, _context) do
    email = BsShitbot.config([:blue_sky, :email])
    pass = BsShitbot.config([:blue_sky, :pass])
    %{did: my_did, access_jwt: access_jwt} = BsShitbot.JWTS.authenticate_with_email(email, pass)

    messages
    |> Enum.map(fn %{data: data} -> data end)
    |> List.flatten()
    |> Enum.map(fn %{"profiles" => profiles} -> profiles end)
    |> List.flatten()
    |> Flow.from_enumerable()
    |> Flow.filter(fn profile ->
      below_threshold?(profile)
    end)
    |> Enum.to_list()
    |> BsShitbot.BlueskyClient.Lists.mass_assign_users_to_list(
      access_jwt,
      my_did,
      "at://did:plc:4nd2nxnptle7cdq3thxtsqe6/app.bsky.graph.list/3lfikbvo2n52b"
    )

    messages
  end

  # defp above_threshold?(profile) do
  #   below_ratio?(
  #     profile.followers_count || 0,
  #     profile.following_count || 0,
  #     200,
  #     0.01,
  #     profile.did
  #   ) ||
  #     below_ratio?(
  #       profile.followers_count || 0,
  #       profile.posts_count || 0,
  #       1000,
  #       0.001,
  #       profile.did
  #     )
  # end

  defp below_threshold?(profile) do
    below_ratio?(
      profile["followersCount"],
      profile["followsCount"],
      200,
      0.01,
      profile["did"]
    ) ||
      below_ratio?(
        profile["followersCount"],
        profile["postsCount"],
        1000,
        0.001,
        profile["did"]
      )
  end

  defp below_ratio?(_target, following, following_threshold, _, _did)
       when following < following_threshold,
       do: false

  defp below_ratio?(target, following, _following_threshold, ratio, _did) do
    target / following <= ratio
  end

  def match_any?(_substrings, nil), do: false

  def match_any?(substrings, string) when is_list(substrings) do
    substrings
    |> Enum.any?(fn substring ->
      escaped_pattern = Regex.escape(substring)
      regex = ~r/#{escaped_pattern}/
      Regex.match?(regex, string)
    end)
  end
end
