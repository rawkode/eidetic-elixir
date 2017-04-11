defmodule Test.Eidetic.EventStore.GenServer do
  use ExUnit.Case, async: true
  require Logger

  test "It can store an event" do
    user = Example.User.register(forename: "James", surname: "Hetfield")
    user = Example.User.rename(user, forename: "Papa", surname: "Hetfield")

    for event <- user.meta.uncommitted_events do
      assert [object_identifier: object_identifier] = GenServer.call(:eidetic_eventstore_adapter, {:record, event})
    end

    {:ok, events} = GenServer.call(:eidetic_eventstore_adapter, {:fetch, user.meta.identifier})

    assert length(events) == 2
    assert user.meta.uncommitted_events == events
  end
end
