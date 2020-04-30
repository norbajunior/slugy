defmodule Slugy.Support.PostWithMapField do
  use Ecto.Schema
  import Ecto.Changeset
  import Slugy, only: [slugify: 2]

  embedded_schema do
    field(:data, :map)
    field(:slug, :string)
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:data])
    |> slugify([:data, :title])
  end
end
