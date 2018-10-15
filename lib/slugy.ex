defmodule Slugy do
  @moduledoc ~S"""
  A Phoenix library to generate slug for your schema fields

  ## Examples

  Let's suppose we have a `Post` schema and we want to generate a slug from `title` field and save it to the `slug` field. To achieve that we need to call `slugify/2` following the changeset pipeline passing the desireable field. `slugify/2` generates the slug and put it to the changeset.

      defmodule Post do
        import Slugy, only: [slugify: 2]

        schema "posts" do
          field :title, :string
          field :body, :text
          field :slug, :string
        end

        def changeset(post, attrs) do
          post
          |> cast(attrs, [:title, :body])
          |> slugify(:title)
        end
      end

  Running this code on iex console you can see the slug generated as a new change to be persisted.

    	iex> changeset = Post.changeset(%Post{}, %{title: "A new Post"})
    	%Ecto.Changeset{changes: %{title: "A new Post", slug: "a-new-post"}}

  Slugy just generates a slug if the field's value passed to `slugify/2` comes with a new value to persist in `attrs` (in update cases) or if the struct is a new record to save.
  """
  import Ecto.Changeset
  alias Slugy.Slug

  @doc ~S"""
  ### Usage

  The `slugify/2` expects a changeset as a first parameter and an atom on the second one.
  The function will check if there is a change on the `title` field and if affirmative generates the slug and assigns to the `slug` field, otherwise do nothing and just returns the changeset.

  iex> slugify(changeset, :title)
  %Ecto.Changeset{changes: %{slug: "content-1"}}

  ### Slugify from an embedded struct field

  In rare cases you need to generate slugs from a field inside a embeded structure that represents a jsonb column on your database.

  For example by having a struct like below and we want a slug from `data -> title`:

      %Content{
      type: "text",
      data: %{title: "Content 1", external_id: 1}
      }

  Just pass a list with the keys following the path down to the desirable field.

      iex> slugify(changeset, [:data, :title])
      %Ecto.Changeset{changes: %{slug: "content-1"}}

  ### Custom slug

  If you want a custom slug composed for more than one fields **e.g.** a post `title` and the `type` like so `"how-to-use-slugy-video"` you need to implement the `Slug protocol` that extracts the desirable fields to generate the slug.

      defmodule Post do
      # ...
      end

      defimpl Slugy.Slug, for: Post do
        def to_slug(%{title: title, type: type}) do
          "#{title} #{type}"
        end
      end

  So, `%Post{title: "A new Post", type: "video"}` with the above `Slug` protocol implementation will have a slug like so `a-new-post-video`

  ## Routes

  And lastly for having our routes with the slug we just need to implement the `Phoenix.Param` protocol to our slugified schemas. `Phoenix.Param` will extract the slug in place of the `:id`.

      defmodule Post do
        @derive {Phoenix.Param, key: :slug}
        schema "posts" do
        # ...
        end

        def changeset(post, attrs) do
        # ...
        end
      end

  For more information about `Phoenix.Param` protocol see in [https://hexdocs.pm/phoenix/Phoenix.Param.html](https://hexdocs.pm/phoenix/Phoenix.Param.html)

  ## Installation

  Add to your `mix.exs` file.

      def deps do
      [
        {:slugy, "~> 1.0.0"}
      ]
      end

  Don’t forget to update your dependencies.

      $ mix deps.get

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
