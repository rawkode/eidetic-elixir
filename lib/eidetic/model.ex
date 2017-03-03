defmodule Eidetic.Model do
  @moduledoc false
  @doc false
  defmacro __using__(fields: fields) do
    quote do
      defstruct unquote(fields) ++ [:meta]

      @doc false
      defmodule Meta do
        defstruct identifier: nil, serial_number: 0, uncommitted_events: []
      end

      @doc false
      def initialise() do
        %__MODULE__{meta: %Meta{}}
      end

      @doc false
      def initialise([]) do
        initialise()
      end

      @doc false
      def initialise(event = %Eidetic.Event{}) do
        initialise([event])
      end

      @doc false
      def initialise([head|tail]) do
        initialise()
          |> _apply_event(head)
          |> initialise(tail)
      end

      @doc false
      defp initialise(model, [head | tail]) do
        model
          |> _apply_event(head)
          |> initialise(tail)
      end

      @doc false
      defp initialise(model, []) do
        model
      end

      @doc false
      defp _apply_event(model, events) when is_list(events) do
        Enum.reduce(events, model, fn(event, model) -> _apply_event(event, model) end)
      end

      @doc false
      defp _apply_event(model, event = %Eidetic.Event{}) do
        try do
          model
            |> apply_event(event)
            |> adjust_meta(event)
        rescue
          error -> raise RuntimeError, message: "Unsupported event: #{event.type}, version #{event.version}"
        end

      end

      @doc false
      defp apply_event("Never gonna give you up", "Never gonna let you down") do
          raise RuntimeError, message: "Or hurt you"
      end

      @doc false
      defp adjust_meta(model = %__MODULE__{}, event = %Eidetic.Event{}) do
        new_model = %{model | meta: %Meta{
          serial_number: model.meta.serial_number + 1,
          uncommitted_events: model.meta.uncommitted_events ++ [event]
        }}
      end
	  end
  end
end

