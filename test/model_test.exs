defmodule Test.Eidetic.Model do
  use ExUnit.Case

  @user_events %{
    registered: %Eidetic.Event{
      type: "UserRegistered",
      version: 1,
      payload: %{
        forename: "Darrell",
        surname: "Abbott"
      }
    },
    renamed: %Eidetic.Event{
      type: "UserRenamed",
      version: 1,
      payload: %{
        forename: "Dimebag",
        surname: "Darrell"
      }
    },
    unhandled: %Eidetic.Event{
      type: "UserChangedTheirName",
      version: 2,
      payload: %{
        forename: "Dimebag",
        surname: "Darrell"
      }
    }
  }

  test "Can create a new User" do
    assert %Example.User{forename: "Darrell", surname: "Abbott"} = Example.User.register(forename: "Darrell", surname: "Abbott")
  end

  test "Can load a user from a single event" do
    user = Example.User.load("my-identifier", Map.get(@user_events, :registered))

    assert %Example.User{forename: "Darrell", surname: "Abbott"} = user
    assert %Example.User{meta: %Example.User.Meta{serial_number: 1}} = user
    assert %Example.User{meta: %Example.User.Meta{uncommitted_events: []}} = user
  end

  test "Can load a user from a list of events" do
    list_of_events = [Map.get(@user_events, :registered), Map.get(@user_events, :renamed)]

    user = Example.User.load("my-identifier", list_of_events)

    assert %Example.User{forename: "Dimebag", surname: "Darrell"} = user
    assert %Example.User{meta: %Example.User.Meta{serial_number: 2}} = user
    assert %Example.User{meta: %Example.User.Meta{uncommitted_events: []}} = user
  end

  test "Will raise an error if there is an event that the model cannot handle" do
    assert_raise RuntimeError, ~r/^Unsupported event/, fn -> Example.User.load(UUID.uuid4(), Map.get(@user_events, :unhandled)) end
  end

  test "Can return the identifier when asked" do
    model = Example.User.load("my-identifier", Map.get(@user_events, :registered))

    assert [uuid: _, binary: _,  type: _, version: 4, variant: _] = model
      |> Example.User.identifier()
      |> UUID.info!
  end

  test "Will return an updated model and a list of events to be persisted during commit" do
    model = Example.User.register(forename: "Darrell", surname: "Abbott")

    {new_model, events} = Example.User.commit(model)

    assert length(events)
    assert ^events = [Map.get(@user_events, :registered)]
  end

  end
