defmodule Example.Subscriber do
  use GenServer

  def handle_cast({:publish, event = %Eidetic.Event{}}, _) do
    {:noreply, {}}
  end
end
