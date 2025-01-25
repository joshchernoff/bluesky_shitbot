defmodule BsShitbotWeb.Feed do
  use BsShitbotWeb, :live_view

  alias BsShitbot.BlockedAccounts

  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(BsShitbot.PubSub, "blocks")
    count = BsShitbot.BlockedAccounts.get_totol_count()

    {:ok,
     socket
     |> assign(page: 1, per_page: 20)
     |> assign(:q, nil)
     |> stream(:blocks, [])
     |> assign_paginate_blocks(1)
     |> assign(:total, count)}
  end

  def handle_info(block, socket) do
    count = BlockedAccounts.get_totol_count()

    if socket.assigns.q do
      {:noreply, socket}
    else
      {:noreply, stream_insert(socket, :blocks, block, at: 0) |> assign(:total, count)}
    end
  end

  def handle_event("search", %{"query" => ""}, socket) do
    {:noreply,
     socket
     |> assign(page: 1, per_page: 20)
     |> assign(:q, nil)
     |> stream(:blocks, [], reset: true)
     |> assign_paginate_blocks(1, nil)}
  end

  def handle_event("remove-from-list", %{"did" => did}, socket) do
    profile = BlockedAccounts.get_blocked_account_by_did(did)
    email = BsShitbot.config([:blue_sky, :email])
    pass = BsShitbot.config([:blue_sky, :pass])

    %{access_jwt: access_key, did: did} =
      BsShitbot.JWTS.authenticate_with_email(
        email,
        pass
      )

    BsShitbot.BlueskyClient.Lists.mass_remove_users_from_list([profile], access_key, did)
    {:noreply, socket |> stream_delete(:blocks, profile)}
  end

  def handle_event("search", %{"query" => query}, socket) do
    {:noreply,
     socket
     |> assign(page: 1, per_page: 20)
     |> assign(:q, query)
     |> stream(:blocks, [], reset: true)
     |> assign_paginate_blocks(1, query)}
  end

  def handle_event("next-page", _, socket) do
    %{page: page, q: q} = socket.assigns
    {:noreply, assign_paginate_blocks(socket, page + 1, q)}
  end

  def handle_event("prev-page", %{"_overran" => true}, socket) do
    {:noreply, assign_paginate_blocks(socket, 1, socket.assigns.q)}
  end

  def handle_event("prev-page", _, socket) do
    if socket.assigns.page > 1 do
      %{page: page, q: q} = socket.assigns

      {:noreply, assign_paginate_blocks(socket, page - 1, q)}
    else
      {:noreply, socket}
    end
  end

  defp assign_paginate_blocks(socket, new_page, query \\ nil) when new_page >= 1 do
    %{per_page: per_page, page: cur_page} = socket.assigns

    blocks =
      BlockedAccounts.paginate_blocks(
        q: query,
        offset: (new_page - 1) * per_page,
        limit: per_page
      )

    {blocks, at, limit} =
      if new_page >= cur_page do
        {blocks, -1, per_page * 3 * -1}
      else
        {Enum.reverse(blocks), 0, per_page * 3}
      end

    case blocks do
      [] ->
        assign(socket, end_of_timeline?: at == -1)

      [_ | _] = blocks ->
        socket
        |> assign(end_of_timeline?: false)
        |> assign(:page, new_page)
        |> stream(:blocks, blocks, at: at, limit: limit)
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

  defp time_ago(some_past_time) do
    Timex.format!(some_past_time, "{relative}", :relative)
  end
end
