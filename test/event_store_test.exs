defmodule Test.Eidetic.EventStore do
  use ExUnit.Case, async: true
  require Logger

  test "It can loop uncommitted events and delegate them to the adapter" do
    Process.register(self(), :eidetic_eventstore_adapter)

    user = Example.User.register(forename: "Darrell", surname: "Abbott")
    {:ok, saved_user = %Example.User{}} = Eidetic.EventStore.save(user)

    for event <- user.meta.uncommitted_events do
      assert_received {:"$gen_cast", {:record_event, event}}
    end
  end

  test "It can add subscribers provided through configuration" do
    Process.register(self(), Example.Subscriber.Config)

    user = Example.User.register(forename: "Darrell", surname: "Abbott")
    {:ok, saved_user = %Example.User{}} = Eidetic.EventStore.save(user)

    for event <- user.meta.uncommitted_events do
      assert_received {:"$gen_cast", {:publish, event}}
    end
  end

  test "Subscribers receive events when added to EventStore" do
    Eidetic.EventStore.add_subscriber(Example.Subscriber)
    Process.register(self(), Example.Subscriber)

    user = Example.User.register(forename: "Darrell", surname: "Abbott")
    {:ok, saved_user = %Example.User{}} = Eidetic.EventStore.save(user)

    for event <- user.meta.uncommitted_events do
      assert_received {:"$gen_cast", {:publish, event}}
    end
  end
end

