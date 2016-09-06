defmodule ModelTest do
  use ExUnit.Case
  use Eidetic.Model

  defstruct forename: nil, age: nil

  doctest Eidetic.Model

  test "it can initialise with no events" do
    assert initialise() == {
      :ok,
        %ModelTest {
          forename: nil,
          age: nil
        }
      }
  end

  test "it can initialise with a single CreateUser event" do
    assert initialise([
      %Event {
        type: "CreateUser",
        version: 1,
        datetime: "now",
        "payload": nil
      }
    ]) == { :ok, %ModelTest{
      forename: "David",
      age: 32
    }}
  end

  test "it raises an error when no match can be made on event type and version" do
    assert_raise RuntimeError, ~r/^Unsupported event/, fn -> initialise([
      %Event {
        type: "CreateUser",
        version: 2,
        datetime: "now",
        "payload": nil
      }
    ]) end
  end

  def initialise() do
    { :ok, %ModelTest{ forename: nil, age: nil } }
  end

  def apply_event(%Event{ type: "CreateUser", version: 1 } = event, state) do
    { :ok, %ModelTest { forename: "David", age: 32 } }
  end

  def apply_event(%Event{} = event, state) do
    raise RuntimeError, message: "Unsupported event: #{event.type}, version #{event.version}"
  end

end
