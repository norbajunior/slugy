defmodule Slugy do
  @moduledoc ~S"""
  Slugy is a Phoenix library to generate slugs to ecto schema fields

  Let's suppose we have a Post schema and we want to generate a slug from `title` field
  and save it to the `slug` field. To achieve that we need to call Slugy.slugify/2
  following the changeset pipeline passing the desireable field. Slugy.slugify/2 generates
  the slug and put it to the changeset.

    defmodule Post do
      import Slugy, only: [slugify: 2]

      schema "posts" do
        field :title, :string
        field :body, :text
        field :published_at, :datetime
        field :slug, :string
      end

      def changeset(post, attrs) do
        post
        |> cast(attrs, [:title, :body, :published_at])
        |> slugify(:title)
      end
    end
  """
  import Ecto.Changeset

  @doc ~S"""
  Slugy.slugify/2 puts the slug generated on the given changeset and returns the changeset.

  Returns the changeset itself if there are no changes to apply.

  ## Examples

      iex> slugify(changeset, :name)
      %Ecto.Changeset{changes: %{slug: "a-slug-string-generated-from-name"}}

      iex> slugify(changeset, :name)
      %Ecto.Changeset{}
  """
  def slugify(changeset, key) when is_atom(key) do
    if string = get_change(changeset, key) do
      put_change(changeset, :slug, generate_slug(string))
    else
      changeset
    end
  end

  @doc """
  Returns a downcased dashed string.

  ## Examples

      iex> generate_slug("Vamo que vamo")
      "vamo-que-vamo"
  """
  def generate_slug(str) do
    str
    |> String.normalize(:nfd)
    |> String.replace(~r/[^A-z\s\d]/u, "")
    |> String.replace(~r/\s/, "-")
    |> String.downcase()
  end
end
