defmodule SlugyTest do
  use ExUnit.Case

  alias Ecto.Changeset
  alias Slugy.Support.{Content, Post, PostWithEmbeddedStruct}

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

  test "slugify/1" do
    assert Slugy.slugify("Hey ow lets go") == "hey-ow-lets-go"
    assert Slugy.slugify("Olá, julia") == "ola-julia"
    assert Slugy.slugify("   Please, trim   ") == "please-trim"
    assert Slugy.slugify("Multiple   spaces") == "multiple-spaces"
    assert Slugy.slugify("The Strokes - Under Cover of Darkness") == "the-strokes-under-cover-of-darkness"
    assert Slugy.slugify("Keep the hyphen: build-up") == "keep-the-hyphen-build-up"
    assert Slugy.slugify("Straße, München") == "strasse-muenchen"
  end
end
