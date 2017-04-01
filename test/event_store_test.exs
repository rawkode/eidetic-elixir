defmodule Test.Eidetic.EventStore do
  use ExUnit.Case, async: false
  require Logger

  test "It can loop uncommitted events and delegate them to the adapter" do
    {:ok, user} =
      Example.User.register(forename: "Darrell", surname: "Abbott")
      |>Eidetic.EventStore.save()

    Logger.debug(inspect(user))

    assert {:ok, user} == Eidetic.EventStore.load(Example.User, user.meta.identifier)
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
    {:ok, saved_user} = Eidetic.EventStore.save(user)

    for event <- user.meta.uncommitted_events do
      assert_received {:"$gen_cast", {:publish, event}}
    end
  end
end
