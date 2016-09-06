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

            defp apply_event(_) do
              raise RuntimeError, message: "I have no idea what you're trying to do"
            end
        end
    end
end
