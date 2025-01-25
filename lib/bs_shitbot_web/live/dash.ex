defmodule BsShitbotWeb.Dash do
  use BsShitbotWeb, :live_view

  alias BsShitbot.BlockedAccounts

  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(BsShitbot.PubSub, "blocks")
    count = BsShitbot.BlockedAccounts.get_totol_count()

    {:ok,
     socket
     |> assign(:total, count)}
  end

  def handle_info(_block, socket) do
    count = BlockedAccounts.get_totol_count()
    {:noreply, socket |> assign(:total, count)}
  end
end
