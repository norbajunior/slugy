# Slugy
[![Build Status](https://travis-ci.com/appprova/slugy.svg?branch=master)](https://travis-ci.com/appprova/slugy)

A Phoenix library to generate slug for your schema fields

Let's suppose we have a `Post` schema and we want to generate a slug from `title` field and save it to the `slug` field. To achieve that we need to call `slugify/2` following the changeset pipeline passing the desireable field. `slugify/2` generates the slug and put it to the changeset.

```elixir
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
```

Running this code on iex console you can see the slug generated as a new change to be persisted.

	  iex> changeset = Post.changeset(%Post{}, %{title: "A new Post"})
	  %Ecto.Changeset{changes: %{title: "A new Post", slug: "a-new-post"}}

`slugify/2` just generates a slug if the field's value passed to `slugify/2` comes with a new value to persist in `attrs` (in update cases) or if the struct is a new record to save.

### Usage

The `slugify/2` expects a changeset as a first parameter and an atom on the second one. The function will check if there is a change on the `title` field and if affirmative generates the slug and assigns to the `slug` field, otherwise do nothing and just returns the changeset.

	iex> slugify(changeset, :title)
	%Ecto.Changeset{changes: %{slug: "content-1"}}

### Slugify from an embedded struct field

In rare cases you need to generate slugs from a field inside a embeded structure that represents a jsonb column on your database.

For example by having a struct like below and we want a slug from `data -> title`:

```elixir
%Content{
  type: "text",
  data: %{title: "Content 1", external_id: 1}
}
```
Just pass a list with the keys following the path down to the desirable field.

      iex> slugify(changeset, [:data, :title])
      %Ecto.Changeset{changes: %{slug: "content-1"}}

### Custom slug

If you want a custom slug composed for more than one fields **e.g.** a post `title` and the `type` like so `"how-to-use-slugy-video"` you need to implement the `Slug protocol` that extracts the desirable fields to generate the slug.

```elixir
defmodule Post do
  # ...
end

defimpl Slugy.Slug, for: Post do
  def to_slug(%{title: title, type: type}) do
    "#{title} #{type}"
  end
end
```

So, `%Post{title: "A new Post", body: "Post body", type: "video"}` with the above `Slug` protocol implementation will have a slug like so `a-new-post-video`

### Without a changeset
In cases we just want to get the slug string without a changeset involved we can use
`slugify/1` to achieve that.

    iex> slugify("Slugy is awesome")
    "slugy-is-awesome"

## Routes

And lastly for having our routes with the slug we just need to implement the `Phoenix.Param` protocol to our slugified schemas. `Phoenix.Param` will extract the slug in place of the `:id`.

```elixir
defmodule Post do
  @derive {Phoenix.Param, key: :slug}
  schema "posts" do
  # ...
  end

  def changeset(post, attrs) do
  # ...
  end
end
```

For more information about `Phoenix.Param` protocol see in [https://hexdocs.pm/phoenix/Phoenix.Param.html](https://hexdocs.pm/phoenix/Phoenix.Param.html)

## Add slug field as a unique index

To make sure slug is always unique we can add a unique constraint to our
slug column

```elixir
defmodule MyApp.Migrations.AddSlugToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :slug, :string
    end

    create unique_index(:posts, [:slug])
  end
end
```

And add the `unique_constraint/2` to check in our changeset pipeline.

```elixir
defmodule Post do
  def changeset(post, attrs) do
    # ...
    |> unique_constraint(:slug)
  end
end
```

## Installation

Add to your `mix.exs` file.

```elixir
def deps do
  [
    {:slugy, "~> 1.2.1"}
  ]
end
```
Don’t forget to update your dependencies.

```
$ mix deps.get
```

# Documentation

You can also find the docs here [https://hexdocs.pm/slugy](https://hexdocs.pm/slugy).

# Contribute

Feel free to contribute to this project. If you have any suggestions or bug reports just open an issue or a PR.
