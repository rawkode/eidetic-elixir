defmodule ModelTest do
  use ExUnit.Case

  use Eidetic.Model
  alias Eidetic.Event

  defstruct forename: nil, age: nil

  doctest Eidetic.Model

  test "it can initialise with no events" do
      assert initialise([]) == { :ok, %ModelTest{forename: nil, age: nil} }
  end

  def apply_event([]) do
      %ModelTest{forename: nil, age: nil}
  end

end
