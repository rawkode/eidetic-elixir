defmodule Example.Subscriber do
  require Logger

  def receive(event = %Eidetic.Event{}) do
    Logger.debug("Received an event")
  end
end
