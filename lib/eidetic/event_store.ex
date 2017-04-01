defmodule Eidetic.EventStore do
  # Behaviour
  @callback handle_call({:record, %Eidetic.Event{}}) :: {:ok, [object_identifier: String.t]}
  @callback handle_call({:fetch, String.t}) :: {:ok, [events: [%Eidetic.Event{}]]}

  use Supervisor
  require Logger

  def start_link do
    Logger.debug("Starting with adapter: #{inspect Application.get_env(:eidetic, :eventstore)}")
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(_) do
    children = [
      worker(Application.get_env(:eidetic, :eventstore), [name: :eidetic_eventstore_adapter])
    ]

    Agent.start_link(fn -> MapSet.new end, name: :eidetic_eventstore_pubsub)
    Enum.each(Application.get_env(:eidetic, :eventstore_subscribers), fn(subscriber) ->
      add_subscriber(subscriber)
    end)

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
      Enum.each(Agent.get(:eidetic_eventstore_pubsub, fn subscribers -> subscribers end),
        fn(subscriber) ->
          Logger.debug("Publishing to subscriber #{inspect subscriber}")
          GenServer.cast(subscriber, {:publish, event})
      end)
    end


    {:ok, %{model | meta: Map.put(model.meta, :uncommitted_events, [])}}
  end

  def add_subscriber(subscriber) do
    Agent.update(:eidetic_eventstore_pubsub, &MapSet.put(&1, subscriber))
  end
end
