defmodule BsShitbot.DidProducer do
  use GenStage
  require Logger

  alias BsShitbot.DidBroadway

  def init(opts) do
    {:producer, opts}
  end

  def process_dids(dids) when is_list(dids) do
    DidBroadway
    |> Broadway.producer_names()
    |> List.first()
    |> GenStage.cast({:dids, dids})
  end

  def handle_demand(demand, state) do
    Logger.info("DidBroadway received demand for #{demand} dids")
    events = []
    {:noreply, events, state}
  end

  def handle_cast({:dids, dids}, state) do
    {:noreply, dids, state}
  end
end
