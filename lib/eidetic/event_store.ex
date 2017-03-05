defmodule Eidetic.EventStore do
  use Supervisor
  require Logger

  def start_link do
    Logger.debug("Starting with adapter: #{inspect Application.get_env(:eidetic, :event_store)}")
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(_) do
    children = [
      worker(Application.get_env(:eidetic, :event_store), [name: :event_store_adapter])
    ]

    supervise(children, strategy: :one_for_one)
  end

  def save(model) do
    for event <- model.meta.uncommitted_events do
      GenServer.cast(:event_store_adapter, {:record_event, event})
    end

    {:ok, %{model | meta: Map.put(model.meta, :uncommitted_events, [])}}
  end
end

