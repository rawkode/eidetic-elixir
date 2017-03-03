defmodule Eidetic.Event do
  use Ecto.Schema

  @derive {Poison.Encoder, except: [:__meta__, :__struct__]}
  @primary_key false
  schema "events" do
    field :identifier, Ecto.UUID, primary_key: true
    field :serial_number, :integer, primary_key: true

    field :type, :string
    field :version, :integer

    field :payload, :map

    field :metadata, :map
    field :datetime, Ecto.DateTime
  end
end

