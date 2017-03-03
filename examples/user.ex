defmodule Example.User do
  use Eidetic.Model, fields: [forename: nil, surname: nil]

  def register(forename: forename, surname: surname) do
    emit type: "UserRegistered", version: 1, payload: %{
      forename: forename,
      surname: surname
    }
  end

  def rename(model = %Example.User{}, forename: forename, surname: surname) do
    emit model: model, type: "UserRenamed", version: 1, payload: %{
      forename: forename,
      surname: surname
    }
  end

  defp apply_event(model = %Example.User{}, event = %Eidetic.Event{type: "UserRegistered", version: 1}) do
    %{model | forename: event.payload[:forename], surname: event.payload[:surname]}
  end

  defp apply_event(model = %Example.User{}, event = %Eidetic.Event{type: "UserRenamed", version: 1}) do
    %{model | forename: event.payload[:forename], surname: event.payload[:surname]}
  end
end

