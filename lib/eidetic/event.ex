defmodule Eidetic.Event do
  defstruct identifier: UUID.uuid4(),
    serial_number: 0,
    type: nil,
    version: nil,
    payload: %{},
    metadata: %{},
    datetime: DateTime.utc_now()
end

