defmodule Eidetic do
  @moduledoc """
  Eidetic allows you, with a single line of code, to event sourced your models.

  ## Setting up your model
  ```elixir
  defmodule Example.Person do
    use Eidetic.Model, fields: [forename: nil, surname: nil]
  end
  ```

  ## Extending your model
  Now all you have to do is add `defp apply_event/2` to your model

  ## Examples
  Please checkout the [GitHub Examples](https://github.com/rawkode/eidetic-elixir/tree/master/examples) directory
  """
  use Application

  def start(_type, _args) do
    Eidetic.EventStore.start_link()
  end
end

