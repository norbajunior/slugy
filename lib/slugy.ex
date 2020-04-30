defmodule Slugy do
  @moduledoc ~S"""
  A Phoenix library to generate slug for your schema fields

  ## Examples

  Let's suppose we have a `Post` schema and we want to generate a slug from `title` field and save it to the `slug` field. To achieve that we need to call `slugify/2` following the changeset pipeline passing the desireable field. `slugify/2` generates the slug and put it to the changeset.

      defmodule Post do
        use Ecto.Schema
        import Ecto.Changeset
        import Slugy

        embedded_schema do
          field(:title, :string)
          field(:slug, :string)
        end

        def changeset(post, attrs) do
          post
          |> cast(attrs, [:title, :type])
          |> slugify(:title)
        end
      end

  Running this code on iex console you can see the slug generated as a new change to be persisted.

      iex> Post.changeset(%Post{}, %{title: "A new Post"}).changes
      %{title: "A new Post", slug: "a-new-post"}

  Slugy just generates a slug if the field's value passed to `slugify/2` comes with a new value to persist in `attrs` (in update cases) or if the struct is a new record to save.
  """
  import Ecto.Changeset

  @doc ~S"""
  The `slugify/2` expects a changeset as a first parameter and an atom to the second one.
  The function will check if there is a change on the "key" field and if affirmative generates the slug and assigns to the `slug` field, otherwise do nothing and just returns the changeset.

      iex> Post.changeset(%Post{}, %{title: "A new Post"}).changes
      %{slug: "a-new-post", title: "A new Post"}

  ## Composed slug

  If you need a composed slug **e.g.** a post `title` and the `type` like so `"how-to-use-slugy-video"` you need to pass the `with` key that expects a list of atom keys.

      defmodule Content do
        use Ecto.Schema
        import Ecto.Changeset
        import Slugy

        embedded_schema do
          field :name, :string
          field :type, :string
          field :slug, :string
        end

        def changeset(post, attrs) do
          post
          |> cast(attrs, [:name, :type])
          |> slugify(with: [:name, :type])
        end
      end

      iex> Content.changeset(%Content{}, %{name: "Elixir", type: "video"}).changes
      %{name: "Elixir", type: "video", slug: "elixir-video"}

  ## Slugify from a map field

  In rare cases you need to generate slugs from a field inside a map field that represents a jsonb column on your database.

  For example by having a struct like below and we want a slug from `data -> title`:

      defmodule PostWithMapField do
        use Ecto.Schema
        import Ecto.Changeset
        import Slugy

        embedded_schema do
          field :data, :map
          field :slug, :string
        end

        def changeset(post, attrs) do
          post
          |> cast(attrs, [:data])
          |> slugify([:data, :title])
        end
      end

  Just pass a list with the keys following the path down to the desirable field.

      iex> PostWithMapField.changeset(%PostWithMapField{}, %{data: %{title: "This is my AWESOME title"}}).changes
      %{data: %{title: "This is my AWESOME title"}, slug: "this-is-my-awesome-title"}

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
          {:slugy, "~> 4.0.0"}
        ]
      end

  Don’t forget to update your dependencies.

      $ mix deps.get

  """
  def slugify(changeset, with: fields) when is_list(fields) do
    with true <- any_change?(changeset, fields),
         str when not is_nil(str) <- compose_fields(changeset, fields) do
      put_change(changeset, :slug, slugify(str))
    else
      _ -> changeset
    end
  end

  def slugify(changeset, key) when is_atom(key) do
    if str = get_change(changeset, key) do
      put_change(changeset, :slug, slugify(str))
    else
      changeset
    end
  end

  def slugify(changeset, nested_field) when is_list(nested_field) do
    with str when not is_nil(str) <- get_in(changeset.changes, nested_field) do
      put_change(changeset, :slug, slugify(str))
    else
      _ -> changeset
    end
  end

  @doc """
  Returns a downcased dashed string.

  ## Examples

      iex> Slugy.slugify("Vamo que vamo")
      "vamo-que-vamo"
  """
  def slugify(str) when is_binary(str) do
    str
    |> String.trim()
    |> String.normalize(:nfd)
    |> String.replace(~r/\s\s+/, " ")
    |> String.replace(~r/[^A-z\s\d-]/u, "")
    |> String.replace(~r/\s/, "-")
    |> String.replace(~r/--+/, "-")
    |> String.downcase()
  end

  defp compose_fields(_changeset, []), do: ""

  defp compose_fields(changeset, [head | tail]) do
    "#{get_field(changeset, head)} " <> compose_fields(changeset, tail)
  end

  defp any_change?(changeset, fields) do
    Enum.any?(fields, fn field -> get_change(changeset, field) end)
  end
end
