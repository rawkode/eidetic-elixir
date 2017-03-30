defmodule Test.Eidetic.EventStore do
  use ExUnit.Case, async: true
  require Logger

  setup do
    Process.register(self(), :eidetic_eventstore_adapter)
    :ok
  end

  test "It can loop uncommitted events and delegate them to the adapter" do
    user = Example.User.register(forename: "Darrell", surname: "Abbott")
    {:ok, saved_user = %Example.User{}} = Eidetic.EventStore.save(user)

    for event <- user.meta.uncommitted_events do
      assert_received {:"$gen_cast", {:record_event, event}}
    end
  end
end

