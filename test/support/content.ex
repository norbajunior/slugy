defmodule Slugy.Support.Content do
  use Ecto.Schema
  import Ecto.Changeset
  import Slugy, only: [slugify: 2]

  embedded_schema do
    field(:name, :string)
    field(:type, :string)
    field(:slug, :string)
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:name, :type])
    |> slugify(with: [:name, :type])
  end
end
