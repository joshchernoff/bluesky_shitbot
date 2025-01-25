defmodule BsShitbotWeb.Dash do
  use BsShitbotWeb, :live_view

  alias BsShitbot.BlockedAccounts

  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(BsShitbot.PubSub, "blocks")
    count = BsShitbot.BlockedAccounts.get_totol_count()
    last_hour = BlockedAccounts.get_last_hour_count()

    {:ok,
     socket
     |> assign(total: count, last_hour: last_hour)}
  end

  def handle_info(_block, socket) do
    last_hour = BlockedAccounts.get_last_hour_count()
    count = BlockedAccounts.get_totol_count()
    {:noreply, socket |> assign(total: count, last_hour: last_hour)}
  end
end
