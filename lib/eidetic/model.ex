defmodule Eidetic.Model do
    alias Eidetic.Event

    @doc false
    defmacro __using__(_) do
        quote do
            import Eidetic.Model
            alias Eidetic.Event
        end
    end

    def initialise([ head | tail ]) do
        apply_event(head)
        initialise(tail)
    end

    def initialise([]) do
        {:ok}
    end

    def test() do
        {:ok}
    end
end
