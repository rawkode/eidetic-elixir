defmodule Eidetic.EventStore do
  @moduledoc """
  This module manages loading / saving from / to the EventStore.

  Configuring:

  ```elixir
  confing :eidetic eventstore_adapter: Some.Adapter
  ```

  Using:

  ```elixir
  {:ok, aggregate} = Eidetic.save(an_aggregate)

  aggregate =
    aggregate
    |> Eidetic.save!()
  ```
  """

  @callback handle_call({:record, %Eidetic.Event{}}) :: {:ok, [object_identifier: String.t]}
  @callback handle_call({:fetch, String.t}) :: {:ok, [events: [%Eidetic.Event{}]]}

  use Supervisor
  require Logger

  @doc false
  def start_link do
    Logger.debug("Starting Agent for Subscribers")
    Agent.start_link(fn -> MapSet.new end, name: :eidetic_eventstore_pubsub)
    Enum.each(Application.get_env(:eidetic, :eventstore_subscribers), fn(subscriber) ->
      Logger.debug("Subscriber found in configuration. Adding #{subscriber}")
      add_subscriber(subscriber)
    end)

    Logger.debug("Starting with adapter: #{inspect Application.get_env(:eidetic, :eventstore_adapter)}")
    Supervisor.start_link(__MODULE__, [])
  end

  @doc false
  def init([]) do
    children = [
      worker(Application.get_env(:eidetic, :eventstore_adapter),[[name: :eidetic_eventstore_adapter]])
    ]

    supervise(children, strategy: :one_for_one)
  end

  @doc """
  Save an %Eidetic.Aggregate{}'s uncommitted events to the EventStore
  """
  def save(aggregate) do
    # GenServer.cast(:eventstore_adapter, {:start_transaction})
    for event <- aggregate.meta.uncommitted_events do
      GenServer.call(:eidetic_eventstore_adapter, {:record, event})
    end
    # :ok = GenServer.cast(:eventstore_adapter, {:end_transaction})

    # Transaction didn't fail, publish
    for event <- aggregate.meta.uncommitted_events do
      Enum.each(Agent.get(:eidetic_eventstore_pubsub, fn subscribers -> subscribers end),
        fn(subscriber) ->
          Logger.debug("Publishing to subscriber #{inspect subscriber}")
          GenServer.cast(subscriber, {:publish, event})
      end)
    end

    {:ok, %{aggregate | meta: Map.put(aggregate.meta, :uncommitted_events, [])}}
  end

  @doc """
  Save an %Eidetic.Aggregate{}'s uncommitted events to the EventStore, only returning the aggregate.

  Eventually this will raise an error when a write / transaction fails.
  """
  def save!(aggregate) do
    {:ok, aggregate} = save(aggregate)

    aggregate
  end

  @doc """
  Load events from the EventStore and produce a aggregate
  """
  def load(type, identifier) do
    Logger.debug("I have #{type}")
    {:ok, events} = GenServer.call(:eidetic_eventstore_adapter, {:fetch, identifier})
    {:ok, type.load(identifier, events)}
  end

  @doc """
  Load events from the EventStore and produce a aggregate, only returning the aggregate.
  """
  def load!(type, identifier) do
    {:ok, aggregate} = load(type, identifier)

    aggregate
  end

  @doc """
  Add a subscriber so that they receive notifications whenever an event is
  written to the EventStore
  """
  def add_subscriber(subscriber) do
    Agent.update(:eidetic_eventstore_pubsub, &MapSet.put(&1, subscriber))
  end
end
