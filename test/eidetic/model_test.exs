defmodule ModelTest do
  use ExUnit.Case
  use Eidetic.Model, fields: [forename: nil, age: nil]

  test "Model can be initialised with no events" do
    assert %ModelTest{} = initialise()
    assert %ModelTest{} = initialise([])
  end

  test "Model can be initialised with a single event" do
    model = initialise([event =
      %Event{
        type: "CreateModelTest",
        version: 1,
        serial_number: 1,
        "payload": %{forename: "David", age: 33}
      }])

    assert %ModelTest{forename: "David", age: 33} = model
    assert %ModelTest{meta: %Meta{serial_number: 1}} = model
    assert %ModelTest{meta: %Meta{pending_events: [^event]}} = model
  end

  test "it raises an error when no match can be made on event type and version" do
    assert_raise RuntimeError, ~r/^Unsupported event/, fn -> initialise([
      %Event{
        type: "CreateModelTest",
        version: 2,
        serial_number: 1,
        "payload": %{forename: "David", age: 33}
      }]) end
  end

  def rename(%ModelTest{} = model, forename) do
    event = %Event{
      type: "Rename",
      version: 1,
      datetime: "now",
      payload: %{
        forename: forename
      }
    }

    state = apply_event(event, model)

    { :ok, state: state, event: event }
  end

  defp _apply_event(event = %Event{ type: "CreateModelTest", version: 1 }, model = %ModelTest{}) do
    %{model | forename: event.payload.forename, age: event.payload.age }
  end

  defp _apply_event(%Event{ type: "Rename", version: 1 } = event, %ModelTest{} = state) do
    %{state | forename: event.payload.forename }
  end


end
