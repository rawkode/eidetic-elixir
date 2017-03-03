defmodule Example.Person do
  use Eidetic.Model, fields: [forename: nil, surname: nil]

  defp apply_event(model = %Example.Person{}, event = %Eidetic.Event{type: "PersonWasBorn", version: 1}) do
    %{model | forename: event.payload[:forename], surname: event.payload[:surname]}
  end

  defp apply_event(model = %Example.Person{}, event = %Eidetic.Event{type: "PersonChangedTheirName", version: 1}) do
    %{model | forename: event.payload[:forename], surname: event.payload[:surname]}
  end
end

