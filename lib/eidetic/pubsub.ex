defmodule Eidetic.PubSub do
  require Logger

  def start_link do
    Agent.start_link(fn -> MapSet.new end, name: __MODULE__)
  end

  def add_subscriber(subscriber) do
    Logger.debug("Adding a subscriber: #{inspect subscriber}")
    Agent.update(__MODULE__, &MapSet.put(&1, subscriber))
  end

  def publish(event = %Eidetic.Event{}) do
    Enum.each(Agent.get(__MODULE__, fn subscribers -> subscribers end),
      fn(subscriber) ->
        Logger.debug("Publish an event to #{inspect subscriber}")
      end)
  end
end
