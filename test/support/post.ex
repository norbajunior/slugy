defmodule Slugy.Support.Post do
  use Ecto.Schema
  import Ecto.Changeset
  import Slugy, only: [slugify: 2]

  embedded_schema do
    field(:title, :string)
    field(:slug, :string)
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title])
    |> slugify(:title)
  end
end
