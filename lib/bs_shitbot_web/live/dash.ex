defmodule BsShitbotWeb.Dash do
  use BsShitbotWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="text-center">
      <img src={~p"/images/bot.webp"} class="rounded-full w-40 h-40 mx-auto mb-2 shadow-xl" />
      <h1 class="mb-2">💩 Bluesky Shitbots & Shitbirds Block list 🤖</h1>
      <p class="mb-10">
        A real time status of the shitbot block list for bluesky <br />
        <a
          class="mt-4 block"
          href="https://bsky.app/profile/bs-shitbot.bsky.social/lists/3lfikbvo2n52b"
        >
          <button
            type="button"
            class="inline-flex items-center gap-x-1.5 rounded-md bg-indigo-600 px-2.5 py-1.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
          >
            <svg
              class="-ml-0.5 size-5"
              viewBox="0 0 20 20"
              fill="currentColor"
              aria-hidden="true"
              data-slot="icon"
            >
              <path
                fill-rule="evenodd"
                d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm3.857-9.809a.75.75 0 0 0-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 1 0-1.06 1.061l2.5 2.5a.75.75 0 0 0 1.137-.089l4-5.5Z"
                clip-rule="evenodd"
              />
            </svg>
            Block list here
          </button>
        </a>
      </p>
    </div>
    <ul id="blocks" phx-update="stream" role="list" class="divide-y divide-gray-100">
      <li :for={{id, block} <- @streams.blocks} id={id} class="flex justify-between gap-x-6 py-5">
        <div class="flex min-w-0 gap-x-4">
          <a href={"https://bsky.app/profile/#{block.handle}"}>
            <img class="size-32 flex-none rounded-full bg-gray-50" src={block.avatar_uri} alt="" />
          </a>
          <div class="min-w-0 flex-auto">
            <p class="text-sm/6 font-semibold text-gray-900">
              <a href={"https://bsky.app/profile/#{block.handle}"}>{block.handle}</a>
            </p>
            <p class="mt-1 truncate text-xs/5 text-gray-500">
              Follow back rate: {block.followers_count / block.following_count}
            </p>
            <p class="mt-1 truncate text-xs/5 text-gray-500">
              Post rate per 1k: {block.posts_count / block.following_count}
            </p>
            <p class="mt-1 truncate text-xs/5 text-gray-500">
              <span class="inline-flex items-center rounded-md bg-pink-50 px-2 py-1 text-xs font-medium text-pink-700 ring-1 ring-inset ring-pink-700/10">
                Blocked On: {block.inserted_at}
              </span>
            </p>
          </div>
        </div>
        <div class="hidden shrink-0 sm:flex sm:flex-col sm:items-end">
          <p class="text-sm/6 text-gray-900">Following: {block.following_count}</p>
          <p class="mt-1 text-sm/6 text-gray-900">Followers: {block.followers_count}</p>
          <p class="mt-1 text-sm/6 text-gray-900">Posts: {block.posts_count}</p>
          <p :if={block.state == :update} class="mt-1 text-sm/6 text-gray-900">
            <span class="inline-flex items-center rounded-md bg-yellow-50 px-2 py-1 text-xs font-medium text-yellow-800 ring-1 ring-inset ring-yellow-600/20">
              Updated Counts
            </span>
          </p>
          <p :if={block.state == :new} class="mt-1 text-sm/6 text-gray-900">
            Status:
            <span class="inline-flex items-center rounded-md bg-green-50 px-2 py-1 text-xs font-medium text-green-800 ring-1 ring-inset ring-green-600/20">
              New Block
            </span>
          </p>
        </div>
      </li>
    </ul>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(BsShitbot.PubSub, "blocks")

    {:ok, socket |> stream(:blocks, [])}
  end

  def handle_info(block, socket) do
    {:noreply, stream_insert(socket, :blocks, block, limit: 20, at: 0)}
  end
end
