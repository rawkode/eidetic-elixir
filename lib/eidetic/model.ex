defmodule Eidetic.Model do
    @doc false
    defmacro __using__(_) do
        quote do
            alias Eidetic.Event

            def initialise([head | tail]) do
              initialState = initialise()
              newState = apply_event(head, initialState)
              initialise(tail, newState)
            end

            defp initialise([head | tail], state) do
              newState = apply_event(state, head)
              initialise(tail, newState)
            end

            defp initialise([], state) do
              state
            end
        end
    end
end
