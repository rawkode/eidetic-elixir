defmodule Eidetic.Aggregate do
  require Logger

  @moduledoc """
  This module is responsible for initialising new event sourced aggregates,
  and maintaining their meta data.

  To get started, simply add the following to your module:
  ```elixir
  use Eidetic.Aggregate, fields: [some_field: "default value"]
  ```

  In order to handle new events, you'll need to add `defp apply_event/2`
  functions:

  ```elixir
  defp apply_event(aggregate, event = %Eidetic.Event{type: "MyEventName", version: 1}) do
  ... your logic goes here...
  end
  ```
  """

  @doc false
  defmacro __using__(fields: fields) do
    quote do
      require Logger

      defstruct unquote(fields) ++ [meta: %Eidetic.Meta{}]

      @doc """
      Load a aggregate by providing the identifier and a list of events to process
      """
      def load(identifier, events) do
        Logger.debug("Loading #{__MODULE__} with identifier '#{identifier}' and events #{inspect events}")

        aggregate = %__MODULE__{meta: %Eidetic.Meta{identifier: identifier}}
                    |> initialise(events)

        {aggregate, events} = commit(aggregate)

        aggregate
      end

      @doc """
      Get the identifier of your Eidetic Aggregate
      """
      def identifier(aggregate = %__MODULE__{}) do
        aggregate.meta.identifier
      end

      @doc """
      Get the `serial_number` for your aggregate.

      If you have a aggregate which was constructed from 2 events, you will receive 2
      """
      def serial_number(aggregate = %__MODULE__{}) do
        aggregate.meta.serial_number
      end

      @doc """
      By calling `commit`, you will receive the uncommitted events (to put in your event store)
      and the new aggregate

      ## Example
      ```elixir
      {%Example.User{}, [%Eidetic.Event{}]} = Example.Person.commit(my_person)
      ```
      """
      def commit(aggregate = %__MODULE__{}) do
        Logger.debug("Committing events for '#{__MODULE__}' (Identifier: '#{aggregate.meta.identifier}'), "
        <> "with uncommitted events: #{inspect aggregate.meta.uncommitted_events}")

        {%{aggregate | meta: Map.put(aggregate.meta, :uncommitted_events, [])}, aggregate.meta.uncommitted_events}
      end
      @doc false
      defp initialise() do
        Logger.debug("Creating a new #{__MODULE__}")

        %__MODULE__{}
      end

      @doc false
      defp initialise(aggregate = %__MODULE__{}, [head | tail]) do
        Logger.debug("Rebuilding '#{__MODULE__}' (identifier: '#{identifier(aggregate)}') "
        <> "with events #{inspect [head] ++ tail}")

        aggregate
        |> _apply_event(head)
        |> initialise(tail)
      end

      @doc false
      defp initialise(aggregate = %__MODULE__{}, []) do
        Logger.debug("Completed rebuild of '#{__MODULE__}' (Identifier: '#{identifier(aggregate)}')")

        aggregate
      end

      @doc false
      defp initialise(aggregate = %__MODULE__{}, event = %Eidetic.Event{}) do
        Logger.debug("Applying a single event to '#{__MODULE__}' (Identifier: '#{identifier(aggregate)}')"
        <> ". Event is #{inspect event}")

        _apply_event(aggregate, event)
      end

      @doc false
      defp emit(type: type, version: version, payload: payload) do
        aggregate = %__MODULE__{meta: %Eidetic.Meta{identifier: UUID.uuid4()}}

        Logger.debug("Event Emitted with no aggregate. Generating '#{__MODULE__}' with identifier '#{identifier(aggregate)}'")

        emit aggregate: aggregate, type: type, version: version, payload: payload
      end

      @doc false
      defp emit(aggregate: aggregate = %__MODULE__{}, type: type, version: version, payload: payload) do
        Logger.debug("Event Emitted from '#{__MODULE__}' (identifier: #{identifier(aggregate)}, type: #{type}, version: #{version}, payload: #{inspect payload})")

        event = %Eidetic.Event{
          identifier: identifier(aggregate),
          serial_number: serial_number(aggregate) + 1,
          type: type,
          version: version,
          payload: payload
        }

        _apply_event(aggregate, event)
      end

      @doc false
      defp _apply_event(aggregate, events) when is_list(events) do
        Enum.reduce(events, aggregate, fn(event, aggregate) -> _apply_event(event, aggregate) end)
      end

      @doc false
      defp _apply_event(aggregate = %__MODULE__{}, event = %Eidetic.Event{}) do
        aggregate = Map.put(aggregate, :meta, %{aggregate.meta | serial_number: event.serial_number, uncommitted_events: aggregate.meta.uncommitted_events ++ [event]})

        try do
          apply_event(aggregate, event)
        rescue
            error -> raise RuntimeError, message: "Unsupported event: #{event.type}, version #{event.version}"
        end

      end

      @doc false
      defp apply_event("Never gonna give you up", "Never gonna let you down") do
        raise RuntimeError, message: "Or hurt you"
      end
    end
  end
end
