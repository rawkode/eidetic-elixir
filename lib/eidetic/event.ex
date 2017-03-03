defmodule Eidetic.Event do
  defstruct identifier: nil,
    serial_number: 0,
    type: nil,
    version: nil,
    payload: %{},
    metadata: %{},
    datetime: DateTime.utc_now()
end

