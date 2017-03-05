defmodule Test.Eidetic.EventStore.GenServer do
  use ExUnit.Case, async: true
  require Logger

  @event %Eidetic.Event{
    identifier: UUID.uuid4(),
    serial_number: 1,
    type: "UserRegistered",
    version: 1,
    datetime: DateTime.utc_now(),
    metadata: %{},
    payload: %{
      "forename" => "David",
      "surname" => "McKay"
    }
  }

  setup do
    {:ok, registry} = Eidetic.EventStore.GenServer.start_link()
    {:ok, registry: registry}
  end

  test "It can store an event", %{registry: registry} do
    assert :ok = Eidetic.EventStore.GenServer.record(registry, @event)
    assert :ok = Eidetic.EventStore.GenServer.record(registry, @event)

    events = Eidetic.EventStore.GenServer.fetch(registry, @event.identifier)

    assert length(events) == 2

    for event <- events do
      assert %Eidetic.Event{} = event
    end
  end
end

