defmodule ModelTest do
  use ExUnit.Case
  use Eidetic.Model

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

  def apply_event(%Event{ type: "CreateModelTest", version: 1 } = event, %ModelTest{} = state) do
    %{state | forename: event.payload.forename, age: event.payload.age }
  end

  def apply_event(%Event{} = event, _) do
    raise RuntimeError, message: "Unsupported event: #{event.type}, version #{event.version}"
  end

end
