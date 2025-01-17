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
        # Logger.info("Successfully queried profiles for dids #{dids}")
        Message.update_data(message, fn _ -> profiles end)

      {:error, reason} ->
        # Logger.error("Failed to query dids for #{dids}: #{inspect(reason)}")
        Message.failed(message, reason)
    end

    ########### REMOVE FROM LIST LOGIC
    # dids = Enum.map(list_items, fn {did, _} -> did end)
    # case IdentResolver.get_profiles(dids) do
    #   {:ok, %{"profiles" => profiles}} ->
    #     profiles =
    #       profiles
    #       |> Enum.map(fn %{"did" => did} = profile ->
    #         {_, rkey} = Enum.find(list_items, fn {l_did, _rkey} -> did == l_did end)
    #         rkey = List.last(String.split(rkey, "/"))
    #         {profile, rkey}
    #       end)

    #     # Logger.info("Successfully queried profiles for dids #{dids}")
    #     Message.update_data(message, fn _ -> profiles end)

    #   {:error, reason} ->
    #     Logger.error("Failed to query dids for #{dids}: #{inspect(reason)}")
    #     Message.failed(message, reason)
    # end
  end

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
    |> Enum.map(fn profile ->
      # IO.inspect(%{
      #   followers: profile["followersCount"],
      #   posts: profile["postsCount"],
      #   following: profile["followsCount"],
      #   follower_calc: profile["followersCount"] / profile["followsCount"],
      #   posts_calc: profile["postsCount"] / profile["followsCount"],
      #   follower_2_following: profile["followersCount"] / profile["followsCount"] >= 0.01,
      #   posts_2_following: profile["postsCount"] / profile["followsCount"] >= 0.001,
      #   url: "https://bsky.app/profile/#{profile["did"]}"
      # })
      profile["did"]
    end)
    |> BsShitbot.BlueskyClient.Lists.mass_assign_users_to_list(
      access_jwt,
      my_did,
      "at://did:plc:4nd2nxnptle7cdq3thxtsqe6/app.bsky.graph.list/3lfikbvo2n52b"
    )

    ############### REMOVE FROM LIST
    # messages
    # |> Enum.map(fn m -> m.data end)
    # |> List.flatten()
    # |> Flow.from_enumerable()
    # |> Flow.filter(fn {profile, _rkey} ->
    #   above_ratio?(profile["followersCount"], profile["followsCount"])
    # end)
    # |> Flow.filter(fn {profile, _rkey} ->
    #   !match_any?(
    #     [
    #       "uwu.ai",
    #       "tinyurl.com",
    #       "getallmylinks.com",
    #       "https://gE\u200BtA\u200BlL\u200BmY\u200BlI\u200BnK\u200Bs.com/",
    #       "the bio",
    #       ".carrd.co",
    #       ".crd.c",
    #       ".ju.mp",
    #       # "linktr.ee",
    #       "gofundme.com"
    #     ],
    #     profile["description"]
    #   )
    # end)
    # |> Flow.partition()
    # |> Flow.map(fn {%{"did" => _did}, rkey} -> rkey end)
    # |> Enum.to_list()
    # |> BsShitbot.BlueskyClient.Lists.mass_remove_users_from_list(
    #   access_jwt,
    #   my_did
    # )
    # ####################
    messages
  end

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
