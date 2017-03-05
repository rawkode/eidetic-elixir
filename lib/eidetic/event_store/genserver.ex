defmodule Eidetic.EventStore.GenServer do
  use GenServer
  require Logger

  @doc "Record a single event into the event-store"
  def record(registry, event = %Eidetic.Event{}) do
    GenServer.cast(registry, {:record_event, event})
  end

  @doc "Fetch a single event from the event-store"
  def fetch(registry, identifier) do
    GenServer.call(registry, {:fetch_event, identifier})
  end

  @doc """
  Start our GenServer based EventStore
  """
	def start_link(state \\ %{}) do
    GenServer.start_link(__MODULE__, state, [])
  end

  @doc false
	def init(state) do
	  {:ok, state}
  end

  @doc false
  def handle_cast({:record_event, event = %Eidetic.Event{}}, state) do
    Logger.debug("Updating state #{inspect state} with #{inspect event}")
    {:noreply, Map.update(state, event.identifier, [event], &(&1 ++ [event]))}
  end

  @doc false
  def handle_call({:fetch_event, identifier}, _from, state) do
    Logger.debug("Looking for #{identifier} in state #{inspect state}")
    {:reply, Map.get(state, identifier, nil), state}
  end
end

