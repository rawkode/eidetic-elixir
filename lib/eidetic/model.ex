defmodule Eidetic.Model do
  @doc false

  @doc false
  defmacro __using__(fields: fields) do
    quote do
      alias Eidetic.Event

      defstruct unquote(fields) ++ [:meta]

      @doc false
      defmodule Meta do
        defstruct identifier: nil, serial_number: 0, pending_events: []
      end

      @doc false
      def initialise() do
        %__MODULE__{meta: %Meta{}}
      end

      @doc false
      defp initialise([]) do
        initialise()
      end

      defp initialise([head|tail]) do
        new_state = apply_event(head, initialise())

        initialise(tail, new_state)
      end

      @doc false
      defp initialise([head | tail], state) do
        newState = apply_event(head, state)
        initialise(tail, newState)
      end

      @doc false
      defp initialise([], state) do
        state
      end

      @doc false
      defp apply_event(events, model) when is_list(events) do
        Enum.reduce(events, model, fn(event, state) -> apply_event(event, state) end)
      end

      @doc false
      defp apply_event(%Eidetic.Event{} = event, state) do
        try do
          new_state = _apply_event(event, state)
          adjust_meta(new_state, event)
        rescue
          error -> raise RuntimeError, message: "Unsupported event: #{event.type}, version #{event.version}"
        end

      end

      @doc false
      defp adjust_meta(model = %__MODULE__{}, event = %Eidetic.Event{}) do
        new_model = %{model | meta: %Meta{
          serial_number: model.meta.serial_number + 1,
          pending_events: model.meta.pending_events ++ [event]
        }}
      end
	  end
  end
end

