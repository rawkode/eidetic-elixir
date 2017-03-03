# Eidetic

*WARNING:* This is under active development

Initial implementation of an event sourced model that can be used in Elixir.

## Installing
```elixir
def deps do
  [{:eidetic, "~> 0.0.2"}]
end
```

## Creating Your First EventSourced Model

Please check out the [examples](/examples)

```elixir
defmodule MyModel do
  use Eidetic.Model, fields: [forename: nil, surname: nil]
end
```

