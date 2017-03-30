defmodule Eidetic.EventStore do
  use Supervisor
  require Logger

  def start_link do
    Logger.debug("Starting with adapter: #{inspect Application.get_env(:eidetic, :eventstore)}")
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(_) do
    children = [
      worker(Application.get_env(:eidetic, :eventstore), [name: :eidetic_eventstore_adapter]),
      worker(Eidetic.PubSub, [name: :eidetic_eventstore_pubsub])
    ]

    supervise(children, strategy: :one_for_one)
  end

  def save(model) do
    # GenServer.cast(:eventstore_adapter, {:start_transaction})
    for event <- model.meta.uncommitted_events do
      GenServer.cast(:eidetic_eventstore_adapter, {:record_event, event})
    end
    # :ok = GenServer.cast(:eventstore_adapter, {:end_transaction})

    # Transaction didn't fail, publish
    for event <- model.meta.uncommitted_events do
      GenServer.cast(:eidetic_eventstore_pubsub, {:publish, event})
    end


    {:ok, %{model | meta: Map.put(model.meta, :uncommitted_events, [])}}
  end

  def add_subscriber(subscriber) do
    Logger.debug("Howdy")
    GenServer.cast(:eidetic_eventstore_pubsub, {:add_subscriber, subscriber})
  end
end

