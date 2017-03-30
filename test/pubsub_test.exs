defmodule Test.Eidetic.PubSub do
  use ExUnit.Case, async: true
  require Logger

  setup do
    Process.register(self(), :eidetic_eventstore_pubsub)
    :ok
  end

  test "It can react to events via subscription" do
    Eidetic.EventStore.add_subscriber Example.Subscriber

    assert_received {:"$gen_cast", {:add_subscriber, Example.Subscriber}}

    user = Example.User.register(forename: "Darrell", surname: "Abbott")
    {:ok, saved_user = %Example.User{}} = Eidetic.EventStore.save(user)

    for event <- user.meta.uncommitted_events do
      assert_received {:"$gen_cast", {:publish, event}}
    end
  end
end

