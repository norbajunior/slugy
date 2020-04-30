defmodule Slugy.Support.Content do
  use Ecto.Schema

  embedded_schema do
    field(:name, :string)
    field(:type, :string)
    field(:slug, :string)
  end
end

defimpl Slugy.Slug, for: Slugy.Support.Content do
  def to_slug(%{name: name, type: type}) do
    "#{name} #{type}"
  end
end
