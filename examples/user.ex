defmodule Example.User do
  use Eidetic.Aggregate, fields: [forename: nil, surname: nil]

  def register(forename: forename, surname: surname) do
    emit type: "UserRegistered", version: 1, payload: %{
      forename: forename,
      surname: surname
    }
  end

  def rename(aggregate = %Example.User{}, forename: forename, surname: surname) do
    emit aggregate: aggregate, type: "UserRenamed", version: 1, payload: %{
      forename: forename,
      surname: surname
    }
  end

  defp apply_event(aggregate = %Example.User{}, event = %Eidetic.Event{type: "UserRegistered", version: 1}) do
    %{aggregate | forename: event.payload[:forename], surname: event.payload[:surname]}
  end

  defp apply_event(aggregate = %Example.User{}, event = %Eidetic.Event{type: "UserRenamed", version: 1}) do
    %{aggregate | forename: event.payload[:forename], surname: event.payload[:surname]}
  end
end

