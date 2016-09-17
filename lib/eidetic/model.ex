defmodule Eidetic.Model do
    @doc false
    defmacro __using__(_) do
        quote do
            alias Eidetic.Event

            def initialise([head | tail]) do
              # Here I am relying on the implementing model to have provided this function ...
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

            defp apply_event(%Event{} = event, _) do
              raise RuntimeError, message: "Unsupported event: #{event.type}, version #{event.version}"
            end
        end
    end
end
