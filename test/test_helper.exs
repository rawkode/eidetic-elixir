Application.put_env(:eidetic, :eventstore_adapter, Eidetic.EventStore.GenServer)

Application.put_env(:eidetic, :eventstore_subscribers, [
  Example.Subscriber.Config
])

Eidetic.EventStore.start_link()
ExUnit.start()
