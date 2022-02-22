defmodule PersonCreated do
  use Cqrs.DomainEvent

  field :id, :binary_id
  field :name, :string
end