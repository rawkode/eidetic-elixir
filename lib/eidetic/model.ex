defmodule Eidetic.Model do
  @moduledoc """
  This module is responsible for initialising new event sourced models,
  and maintaining their meta data.

  To get started, simply add the following to your model:
  ```elixir
  use Eidetic.Model, fields: [... your fields ...]
  ```

  In order to handle new events, you'll need to add `defp apply_event/2`
  functions:

  ```elixir
  defp apply_event(model, event = %Eidetic.Event{type: "MyEventName", version: 1}) do
    ... your logic goes here...
  end
  ```
  """

  @doc false
  defmacro __using__(fields: fields) do
    quote do
      require Logger

      defstruct unquote(fields) ++ [:meta]

      @doc false
      defmodule Meta do
        defstruct identifier: UUID.uuid4(), serial_number: 0, uncommitted_events: []
      end

      @doc """
      Load a model by providing the identifier and a list of events to process
      """
      def load(identifier, events) do
        Logger.debug("Loading #{__MODULE__} with identifier '#{identifier}' and events #{inspect events}")

        {model, events} = %__MODULE__{meta: %Meta{identifier: identifier}}
          |> initialise(events)
          |> commit()
        model
      end

      @doc """
      Get the identifier of your Eidetic Model
      """
      def identifier(model = %__MODULE__{}) do
        model.meta.identifier
      end

      @doc """
      Get the `serial_number` for your model.

      If you have a model which was constructed from 2 events, you will receive 2
      """
      def serial_number(model = %__MODULE__{}) do
        model.meta.serial_number
      end

      @doc """
      By calling `commit`, you will receive the uncommitted events (to put in your event store)
      and the new model

      ## Example
      ```elixir
      {%Example.User{}, [%Eidetic.Event{}]} = Example.Person.commit(my_person)
      ```
      """
      def commit(model = %__MODULE__{}) do
        Logger.debug("Committing events for '#{__MODULE__}' (Identifier: '#{model.meta.identifier}'), "
          <> "with uncommitted events: #{inspect model.meta.uncommitted_events}")

        {%{model | meta: Map.put(model.meta, :uncommitted_events, [])}, model.meta.uncommitted_events}
      end

      @doc false
      defp initialise() do
        Logger.debug("Creating a new #{__MODULE__}")

        %__MODULE__{meta: %Meta{}}
      end

      @doc false
      defp initialise(model = %__MODULE__{}, [head | tail]) do
        Logger.debug("Rebuilding '#{__MODULE__}' (Identifier: '#{model.meta.identifier}') "
          <> "with events #{inspect [head] ++ tail}")

        model
          |> _apply_event(head)
          |> initialise(tail)
      end

      @doc false
      defp initialise(model = %__MODULE__{}, []) do
        Logger.debug("Completed rebuild of '#{__MODULE__}' (Identifier: '#{model.meta.identifier}')")

        model
      end

      @doc false
      defp initialise(model = %__MODULE__{}, event = %Eidetic.Event{}) do
        Logger.debug("Applying a single event to '#{__MODULE__}' (Identifier: '#{model.meta.identifier}')"
          <> ". Event is #{inspect event}")

        _apply_event(model, event)
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
        Logger.debug("Adjusting metadata for '#{__MODULE__}' (Identifier: '#{model.meta.identifier}'), bumping serial number to #{model.meta.serial_number + 1}")
        %{model | meta: %Meta{
          serial_number: (model.meta.serial_number + 1),
          uncommitted_events: model.meta.uncommitted_events ++ [event]
        }}
      end
	  end
  end
end

