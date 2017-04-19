# Eidetic (EventSourcing for Elixir)

[![Hex.pm](https://img.shields.io/hexpm/v/eidetic.svg)](https://hex.pm/packages/eidetic)
[![Hex.pm](https://img.shields.io/hexpm/l/eidetic.svg)](https://hex.pm/packages/eidetic)
[![Hex.pm](https://img.shields.io/hexpm/dw/eidetic.svg)](https://hex.pm/packages/eidetic)
[![Build Status](https://travis-ci.org/GT8Online/eidetic-elixir.svg?branch=master)](https://travis-ci.org/GT8Online/eidetic-elixir)
[![codecov](https://codecov.io/gh/GT8Online/eidetic-elixir/branch/master/graph/badge.svg)](https://codecov.io/gh/GT8Online/eidetic-elixir)

*WARNING:* This is under active development. Do *NOT* use

Initial implementation of an event sourced model that can be used in Elixir.

## Creating Your First EventSourced Model

Please check out the [examples](/examples)

```elixir
defmodule MyModel do
  use Eidetic.Model, fields: [forename: nil, surname: nil]
end
```
