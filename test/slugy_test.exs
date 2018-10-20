defmodule SlugyTest do
  use ExUnit.Case

  alias Ecto.Changeset
  alias Slugy.Support.Content

  defmodule Post do
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

  defmodule PostWithEmbeddedStruct do
    use Ecto.Schema
    import Ecto.Changeset
    import Slugy, only: [slugify: 2]

    embedded_schema do
      field(:data, :map) # => %PostWithEmbeddedStruct{data: %{title: "A title"}}
      field(:slug, :string)
    end

    def changeset(post, attrs) do
      post
      |> cast(attrs, [:data])
      |> slugify([:data, :title])
    end
  end

  doctest Slugy

  describe "slugify/2" do
    test "puts generated slug on changeset changes and returns changeset" do
      changeset = Changeset.cast(%Post{}, %{title: "A new post"}, [:title])

      assert %{changes: %{slug: "a-new-post"}} = Slugy.slugify(changeset, :title)
    end

    test "returns changeset when there is no changes to apply" do
      changeset = Changeset.cast(%Post{}, %{}, [:title])

      assert %{changes: %{}} = Slugy.slugify(changeset, :name)
    end

    test "puts generated slug from an embedded struct field on changeset changes and returns changeset" do
      changeset =
        %PostWithEmbeddedStruct{}
        |> Changeset.cast(%{data: %{title: "A new post"}}, [:data])

      assert %{changes: %{slug: "a-new-post"}} =
               Slugy.slugify(changeset, [:data, :title])
    end
  end

  describe "slugify/2 in a module that implements Slug protocol" do
    test "puts custom generated slug on changeset changes and returns changeset" do
      attrs = %{name: "Processo Penal", type: "video"}

      changeset = Changeset.cast(%Content{}, attrs, [:name, :type])

      assert %{changes: %{slug: "processo-penal-video"}} = Slugy.slugify(changeset, :name)
    end
  end

  describe "generate_slug/1" do
    assert Slugy.generate_slug("Hey ow lets go") == "hey-ow-lets-go"
    assert Slugy.generate_slug("Olá, julia") == "ola-julia"
  end
end
