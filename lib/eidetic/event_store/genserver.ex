defmodule Eidetic.EventStore.GenServer do
  @moduledoc false
  @behaviour Eidetic.EventStore

  use GenServer
  require Logger

  @doc false
  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, %{}, options)
  end

  @doc false
  def handle_call({:record, event = %Eidetic.Event{}}, _from, state) do
    Logger.debug("Updating state #{inspect state} with #{inspect event}")
    {:reply,
      [object_identifier: event.identifier <> ":" <> Integer.to_string(event.serial_number)],
      Map.update(state, event.identifier, [event], &(&1 ++ [event]))
    }
  end

  @doc false
  def handle_call({:fetch, identifier}, _from, state) do
    Logger.debug("Looking for #{identifier} in state #{inspect state}")
    {:reply, Map.get(state, identifier, nil), state}
  end
end

