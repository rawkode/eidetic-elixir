defmodule Test.Eidetic.Model do
  use ExUnit.Case

  @born_event %Eidetic.Event{
    type: "PersonWasBorn",
    version: 1,
    payload: %{
      forename: "Darrell",
      surname: "Abbott"
    }
  }

  @name_change_event %Eidetic.Event{
    type: "PersonChangedTheirName",
    version: 1,
    payload: %{
      forename: "Dimebag",
      surname: "Darrell"
    }
  }

  @unhandled_event %Eidetic.Event{
    type: "PersonChangedTheirName",
    version: 2,
    payload: %{
      forename: "Dimebag",
      surname: "Darrell"
    }
  }

  test "Model can be initialised with no events" do
    assert %Example.Person{} = Example.Person.initialise()
    assert %Example.Person{} = Example.Person.initialise([])
  end

  test "Model can be initialised with a single event" do
    person = @born_event |> Example.Person.initialise()

    assert %Example.Person{forename: "Darrell", surname: "Abbott"} = person
    assert %Example.Person{meta: %Example.Person.Meta{serial_number: 1}} = person
    assert %Example.Person{meta: %Example.Person.Meta{uncommitted_events: [@born_event]}} = person
  end

  test "Model can be initialised with a stream of events" do
    person = Example.Person.initialise([@born_event, @name_change_event])

    assert %Example.Person{forename: "Dimebag", surname: "Darrell"} = person
    assert %Example.Person{meta: %Example.Person.Meta{serial_number: 2}} = person
    assert %Example.Person{meta: %Example.Person.Meta{uncommitted_events: [@born_event, @name_change_event]}} = person
  end

  test "it raises an error when no match can be made on event type and version" do
    assert_raise RuntimeError, ~r/^Unsupported event/, fn -> Example.Person.initialise(@unhandled_event) end
  end

 end
