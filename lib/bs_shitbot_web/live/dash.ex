defmodule BsShitbotWeb.Dash do
  use BsShitbotWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto text-center max-w-3xl">
      <img src={~p"/images/bot.webp"} class="rounded-full w-32 h-32 mx-auto mb-2 shadow-xl" />
      <h1 class="mb-2 mt-2 text-2xl font-semibold tracking-tight text-pretty text-gray-900 sm:text-3xl">
        💩 Shitbots & Shitbirds 🤖
      </h1>
      <div class="mb-10 mx-auto text-center max-w-xl">
        <p class="font-semi-bold">
          A Bluesky bot that automates a block list of accounts that spam follow.<br />
          🚫 Blocking {@total} accounts
        </p>

        <ul role="list" class="divide-y divide-zinc-100 py-6">
          <li class="flex justify-center py-4 font-bold text-lg">
            <span class="flex">
              🤔 How does this bot decide to add accounts to the list?
            </span>
          </li>

          <li class="py-4">
            Accounts that follow more than 1000 other accounts,<br />
            but also has less than 0.1% Posts. (IE 1000:1, 10_000:10)
          </li>

          <li class="py-4">
            Additionally accounts following more than 200 other accounts,<br />
            but also has less than a 1% follow back count. (IE 200:2, 1000:10)
          </li>
        </ul>

        <div class="mt-2">
          <a class="mr-2" href="https://bsky.app/profile/bs-shitbot.bsky.social/lists/3lfikbvo2n52b">
            <button
              type="button"
              class="inline-flex items-center gap-x-1.5 rounded-md bg-indigo-600 px-2.5 py-1.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
            >
              <.icon name="hero-arrow-right-circle" class="-ml-0.5 size-5" /> Block list here
            </button>
          </a>

          <a class="mr-2" href="https://morphic.pro/payment">
            <button
              type="button"
              class="inline-flex items-center gap-x-1.5 rounded-md bg-red-600 px-2.5 py-1.5 text-sm font-semibold text-white shadow-sm hover:bg-red-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-red-600"
            >
              <.icon name="hero-heart" class="-ml-0.5 size-5" /> Donate to fund project
            </button>
          </a>
          <a href="https://morphic.pro/u/0e9Fu">
            <button
              type="button"
              class="inline-flex items-center gap-x-1.5 rounded-md bg-zinc-600 px-2.5 py-1.5 text-sm font-semibold text-white shadow-sm hover:bg-zinc-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-zinc-600"
            >
              <.icon name="hero-code-bracket" class="-ml-0.5 size-5" /> Source Code
            </button>
          </a>
        </div>

        <div class="flex justify-center py-4">
          <span class="mr-2">Site Created By:</span>
          <a href="/" data-phx-link="redirect" data-phx-link-state="push" class="flex">
            <svg
              class="rotate-180 mr-2 h-6 w-6 object-contain text-zinc-900 fill-current"
              version="1.1"
              xmlns="http://www.w3.org/2000/svg"
              xmlns:xlink="http://www.w3.org/1999/xlink"
              viewBox="0 0 512.021 512.021"
              xml:space="preserve"
            >
              <g>
                <g>
                  <path d="M490.421,137.707c-0.085-1.003-0.149-2.005-0.555-2.987c-0.107-0.256-0.32-0.427-0.448-0.683
    c-0.277-0.533-0.597-0.981-0.96-1.472c-0.725-1.003-1.536-1.835-2.517-2.517c-0.256-0.171-0.363-0.491-0.64-0.64l-224-128
    c-3.285-1.877-7.296-1.877-10.581,0l-224,128c-0.256,0.171-0.363,0.469-0.619,0.64c-1.024,0.704-1.899,1.557-2.645,2.624
    c-0.299,0.427-0.597,0.811-0.832,1.28c-0.149,0.277-0.384,0.469-0.512,0.768c-0.469,1.173-0.619,2.389-0.661,3.584
    c0,0.128-0.107,0.256-0.107,0.384v0.171c0,0.021,0,0.021,0,0.043v234.304c0,0.021,0,0.064,0,0.085v0.064
    c0,0.213,0.149,0.405,0.171,0.619c0.085,1.493,0.32,2.987,1.045,4.352c0.043,0.085,0.128,0.107,0.171,0.192
    c0.277,0.491,0.768,0.811,1.131,1.259c0.789,0.981,1.557,1.941,2.603,2.603c0.107,0.064,0.149,0.192,0.235,0.235l224,128
    c1.664,0.939,3.477,1.408,5.312,1.408s3.648-0.469,5.291-1.408l224-128c0.107-0.064,0.149-0.192,0.256-0.256
    c0.981-0.597,1.664-1.493,2.411-2.389c0.427-0.512,1.003-0.896,1.323-1.472c0.043-0.064,0.107-0.107,0.149-0.171
    c0.576-1.109,0.683-2.325,0.853-3.52c0.064-0.491,0.384-0.939,0.384-1.451V138.688
    C490.677,138.347,490.443,138.048,490.421,137.707z M455.52,136.981l-78.251,31.296L291.211,43.093L455.52,136.981z
    M256.011,29.504l97.067,141.184H158.944L256.011,29.504z M220.747,43.115l-86.037,125.163L56.48,136.981L220.747,43.115z
    M42.677,154.432l80.768,32.32L42.677,332.16V154.432z M138.635,203.392l98.325,178.773L49.248,364.288L138.635,203.392z
    M245.344,482.965l-165.12-94.336l165.12,15.573V482.965z M256.011,372.544l-99.285-180.523h198.571L256.011,372.544z
    M266.677,482.965v-78.571l165.035-15.723L266.677,482.965z M274.997,382.357l98.411-178.901l89.365,160.853L274.997,382.357z
    M469.344,332.203l-80.811-145.451l80.811-32.32V332.203z">
                  </path>
                </g>
              </g>
            </svg>
            <span class="text-xl text-base font-semibold leading-6 text-zinc-900">
              Morphic.Pro
            </span>
          </a>
        </div>
      </div>
    </div>

    <div class="mx-auto px-6 lg:px-8 max-w-7xl">
      <div class="mx-auto max-w-2xl text-center">
        <.search_field id="block_search" value={nil} />

        <div :if={!(@streams.blocks.inserts == [])} class="text-center mx-auto">
          📈 LIVE BLOCK FEED
        </div>
      </div>

      <div
        id="blocks"
        phx-update="stream"
        class="mx-auto mt-16 grid max-w-2xl grid-cols-1 lg:grid-cols-2 gap-x-8 gap-y-20 lg:mx-0 lg:max-w-none xl:grid-cols-3"
      >
        <article
          :for={{id, block} <- @streams.blocks}
          id={id}
          class="flex flex-col items-start justify-between bg-white shadow-xl rounded-t-2xl"
        >
          <div class="relative w-full">
            <a href={"https://bsky.app/profile/#{block.handle}"}>
              <img
                src={block.banner || ~p"/images/bot.webp"}
                alt=""
                class="aspect-video w-full rounded-t-2xl bg-gray-100 object-cover aspect-[4/1]"
              />
            </a>
            <div class="relative mt-4 flex items-center gap-x-4 pb-4 px-4">
              <img src={block.avatar_uri} alt="" class="size-10 rounded-full bg-zin-100" />
              <div class="text-sm/6">
                <p class="font-semibold text-gray-900">
                  <a href={"https://bsky.app/profile/#{block.handle}"}>
                    <span class="absolute inset-0"></span>
                    {block.handle}
                  </a>
                </p>
                <p class="text-gray-600">Acct Created On: {block.account_created_on}</p>
              </div>
            </div>

            <div class="max-w-xl px-4">
              <span class="mb-2 inline-block items-center rounded-md bg-pink-50 px-2 py-1 text-xs font-medium text-pink-700 ring-1 ring-inset ring-pink-700/10">
                Blocked on: {block.inserted_at}
              </span>

              <span class="mb-2  inline-block items-center rounded-md bg-purple-50 px-2 py-1 text-xs font-medium text-purple-700 ring-1 ring-inset ring-purple-700/10">
                Following: {block.following_count}
              </span>

              <span class="mb-2 inline-block items-center rounded-md bg-indigo-50 px-2 py-1 text-xs font-medium text-indigo-700 ring-1 ring-inset ring-indigo-700/10">
                Follower: {block.followers_count}
              </span>

              <span class="mb-2 inline-block items-center rounded-md bg-blue-50 px-2 py-1 text-xs font-medium text-blue-700 ring-1 ring-inset ring-blue-700/10">
                Posts: {block.posts_count}
              </span>

              <span class="inline-block items-center rounded-md bg-green-50 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20">
                RKEY: {block.uri |> String.split("/") |> List.last()}
              </span>
            </div>
          </div>

          <div :if={block.description} class="max-w-xl p-4">
            <div class="group relative">
              <p class="line-clamp-3 text-sm/6 text-gray-600">
                {block.description}
              </p>
            </div>
          </div>
        </article>
      </div>
    </div>

    <div :if={@streams.blocks.inserts == []} class="text-center mx-auto">
      Loading Feed... Please wait
    </div>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(BsShitbot.PubSub, "blocks")
    count = BsShitbot.BlockedAccounts.get_totol_count()

    {:ok,
     socket
     |> stream(:blocks, BsShitbot.BlockedAccounts.last_100_blocked_accounts())
     |> assign(:total, count)
     |> assign(:q, nil)}
  end

  def handle_event("search", %{"query" => ""}, socket) do
    {:noreply,
     socket
     |> stream(:blocks, BsShitbot.BlockedAccounts.last_100_blocked_accounts(), reset: true)
     |> assign(:q, nil)}
  end

  def handle_event("search", %{"query" => query}, socket) do
    search_results = BsShitbot.BlockedAccounts.search(query) |> dbg()
    {:noreply, socket |> stream(:blocks, search_results, reset: true) |> assign(:q, query)}
  end

  def handle_info(block, socket) do
    count = BsShitbot.BlockedAccounts.get_totol_count()

    if socket.assigns.q do
      {:noreply, socket}
    else
      {:noreply,
       stream_insert(socket, :blocks, block, limit: 100, at: 0) |> assign(:total, count)}
    end
  end

  attr :id, :string, required: true
  attr :value, :any, required: true

  defp search_field(assigns) do
    ~H"""
    <div class="flex gap-2 items-center justify-between max-w-lg mx-auto my-10">
      <div class="w-full">
        <label for="search" class="sr-only">Search</label>
        <div class="relative w-full text-zinc-400 dark:text-zinc-600 focus-within:text-zinc-600 dark:focus-within:text-zinc-400">
          <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
            <.icon name="hero-magnifying-glass" />
          </div>
          <form phx-change="search" onkeydown="return event.key != 'Enter';">
            <input
              id={"#{@id}-search-field"}
              class="w-full shadow-md text-zinc-900 rounded-md border-0 bg-zinc-100 py-1.5 pl-10 pr-3 focus:ring-2 focus:ring-indigo-600 sm:text-sm sm:leading-6"
              placeholder="Search handle or DID"
              type="search"
              name="query"
              value={@value}
              phx-debounce="500"
            />
          </form>
        </div>
      </div>
    </div>
    """
  end
end
