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
  alias Slugy.Slug

  @doc ~S"""
  Slugy.slugify/2 puts the slug generated on the given changeset and returns the changeset.

  Returns the changeset itself if there are no changes to apply.

  ## Examples

      iex> slugify(changeset, :name)
      %Ecto.Changeset{changes: %{slug: "a-slug-string-generated-from-name"}}

      iex> slugify(changeset, :name)
      %Ecto.Changeset{}

  ## Slugify a field from a embedded struct

  In rare cases you need to generate the slug from a field inside another structure.
  Just pass a list with the keys down to the desirable field.

      %Content{
        type: "text",
        data: %{title: "Content 1", external_id: 1}
      }

      iex> slugify(changeset, [:data, :title])
      %Ecto.Changeset{changes: %{slug: "content-1"}}

  ## Custom slug

  If you want a custom slug composed for more than one fields e.g. a post title and the publication date
  like so "how-to-use-slugy-2018-10-10" you need to implement the `Slugy.Slug protocol` that extracts
  the desirable fields to generate the slug

      defimpl Slugy.Slug, for: Post do
        def to_slug(%{title: title, published_at: published_at}) do
          "#{title} #{published_at}"
        end
      end

  But you still have to use `Slugy.slugify/2` in changeset function like shown
  on above examples to know whether the field was changed or not.
  """
  def slugify(changeset, key) when is_atom(key) do
    if str = get_change(changeset, key) do
      do_slugify(changeset, str)
    else
      changeset
    end
  end

  def slugify(changeset, nested_field) when is_list(nested_field) do
    with str when not is_nil(str) <- get_in(changeset.changes, nested_field) do
      do_slugify(changeset, str)
    else
      _ -> changeset
    end
  end

  defp do_slugify(changeset, str) do
    struct = Map.merge(changeset.data, changeset.changes)

    if Slug.impl_for(struct) do
      slug = struct |> Slug.to_slug() |> generate_slug()

      put_change(changeset, :slug, slug)
    else
      put_change(changeset, :slug, generate_slug(str))
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

defprotocol Slugy.Slug do
  @moduledoc ~S"""
  A protocol that builds a string to converts into a slug

  This protocol is used by Slugy.slugify/2. For example, when you
  want a custom slug for a Post, composed by the `title` and the
  `published_at` fields:

      "how-to-use-slugy-2018-10-10"

  Suppose you have a Post module with the following fields:

      defmodule Post do
        schema "posts" do
          field :title, :string
          field :body, :text
          field :published_at, :datetime
        end
      end

  You need to implement the Slugy.Slug protocol to achieve that:

      defimpl Slugy.Slug, for: Post do
        def to_slug(%{title: title, published_at: published_at}) do
          "#{title} #{published_at}"
        end
      end

  Slugy internally uses this string to build your custom slug.
  """
  def to_slug(struct)
end
