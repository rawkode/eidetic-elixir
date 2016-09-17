defmodule ModelTest do
  use ExUnit.Case
  alias Eidetic.Event;

  defstruct forename: nil, age: nil

  doctest Eidetic.Model

  test "it can initialise with no events" do
    assert initialise() == %ModelTest {
      forename: nil,
      age: nil
    }
  end

  test "it can initialise with a single CreateModelTest event" do
    assert initialise([
      %Event {
        type: "CreateModelTest",
        version: 1,
        datetime: "now",
        "payload": %{ forename: "David", age: 32 }
      }
    ]) == %ModelTest{
      forename: "David",
      age: 32
    }
  end

  test "it raises an error when no match can be made on event type and version" do
    assert_raise RuntimeError, ~r/^Unsupported event/, fn -> initialise([
      %Event {
        type: "CreateModelTest",
        version: 2,
        datetime: "now",
        "payload": %{ forename: "David", age: 32 }
      }
    ]) end
  end

  def initialise() do
    %ModelTest{ forename: nil, age: nil }
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

  defp apply_event(%Event{ type: "CreateModelTest", version: 1 } = event, %ModelTest{} = state) do
    %{state | forename: event.payload.forename, age: event.payload.age }
  end

  defp apply_event(%Event{ type: "Rename", version: 1 } = event, %ModelTest{} = state) do
    %{state | forename: event.payload.forename }
  end

  use Eidetic.Model

end
