# Slugy
[![Build Status](https://travis-ci.com/appprova/slugy.svg?branch=master)](https://travis-ci.com/appprova/slugy)

A Phoenix library to generate slug for your schema fields

Let's suppose we have a `Post` schema and we want to generate a slug from `title` field and save it to the `slug` field. To achieve that we need to call `slugify/2` following the changeset pipeline passing the desireable field. `slugify/2` generates the slug and put it to the changeset.

```elixir
defmodule Post do
  import Slugy

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

```
iex> changeset = Post.changeset(%Post{}, %{title: "A new Post"})
%Ecto.Changeset{changes: %{title: "A new Post", slug: "a-new-post"}}
```

`slugify/2` just generates a slug if the field's value passed to `slugify/2` comes with a new value to persist in `attrs` (in update cases) or if the struct is a new record to save.

### Usage

The `slugify/2` expects a changeset as a first parameter and an atom on the second one. The function will check if there is a change on the `title` field and if affirmative generates the slug and assigns to the `slug` field, otherwise do nothing and just returns the changeset.

```
iex> Slugy.slugify(changeset, :title)
%Ecto.Changeset{changes: %{slug: "content-1"}}
```

### Composed slug

If you want a custom composed slug for more than one field **e.g.** a content `name` and the `type` like so `"how-to-use-slugy-video"` you need to pass the `with` key that expects a list of fields.

```elixir
defmodule Content do
  # ...

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:name, :type])
    |> slugify(with: [:name, :type])
  end
end
```

```
iex> Content.changeset(%Content{}, %{name: "How to use Slugy", type: "video"}).changes
%{slug: "How to use Slugy", type: "video", slug: "how-to-use-slugy-video"}
```

### Slugify from a map field

In rare cases you need to generate slugs from a key value inside a map field that represents a jsonb column on your database.

For example by having a struct like below and we want a slug from `data -> title`:

```elixir
%Content{
  type: "text",
  data: %{title: "Content 1", external_id: 1}
}
```
Just pass a list with the keys following the path up to the desirable field.

```
iex> Slugy.slugify(changeset, [:data, :title])
%Ecto.Changeset{changes: %{slug: "content-1"}}
```

### Without a changeset
In cases we just want to get the slug string without a changeset involved we can use
`slugify/1` to achieve that.

```
iex> Slugy.slugify("Slugy is awesome")
"slugy-is-awesome"
```

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

To make sure slug is always unique we can add a unique constraint to our slug column

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
    {:slugy, "~> 4.0.0"}
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
