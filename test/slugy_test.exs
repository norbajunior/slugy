defmodule SlugyTest do
  use ExUnit.Case, async: true

  alias Ecto.Changeset
  alias Slugy.Support.{Content, Post, PostWithMapField}

  doctest Slugy

  describe "slugify/2" do
    test "puts generated slug on changeset changes and returns changeset" do
      changeset = Changeset.cast(%Post{}, %{title: "A new post"}, [:title])

      assert %{changes: %{slug: "a-new-post"}} = Slugy.slugify(changeset, :title)
    end

    test "returns changeset when there is no changes to apply" do
      changeset = Changeset.cast(%Post{}, %{}, [:title])

      assert %{changes: %{}} = Slugy.slugify(changeset, :title)
    end

    test "puts generated slug from an embedded struct field on changeset changes and returns changeset" do
      changeset =
        %PostWithMapField{}
        |> Changeset.cast(%{data: %{title: "A new post"}}, [:data])

      assert %{changes: %{slug: "a-new-post"}} = Slugy.slugify(changeset, [:data, :title])
    end

    test "puts composed generated slug on changeset changes and returns changeset" do
      attrs = %{name: "Processo Penal", type: "video"}

      changeset = Changeset.cast(%Content{}, attrs, [:name, :type])

      assert %{changes: %{slug: "processo-penal-video"}} =
               Slugy.slugify(changeset, with: [:name, :type])
    end

    test "if just one of the fields has changes generate the slug and returns the changeset" do
      attrs = %{type: "image"}

      changeset =
        %Content{name: "Processo Penal", type: "video"}
        |> Changeset.cast(attrs, [:name, :type])

      assert %{changes: %{slug: "processo-penal-image"}} =
               Slugy.slugify(changeset, with: [:name, :type])
    end

    test "if none of the fields has changes does not generate the slug and returns the changeset" do
      attrs = %{name: "Processo Penal", type: "video"}

      changeset =
        %Content{name: "Processo Penal", type: "video", slug: "processo-penal-video"}
        |> Changeset.cast(attrs, [:name, :type])

      assert %{changes: %{}} = Slugy.slugify(changeset, with: [:name, :type])
    end
  end

  test "slugify/1" do
    assert Slugy.slugify("Hey ow lets go") == "hey-ow-lets-go"
    assert Slugy.slugify("Olá, julia") == "ola-julia"
    assert Slugy.slugify("   Please, trim   ") == "please-trim"
    assert Slugy.slugify("Multiple   spaces") == "multiple-spaces"

    assert Slugy.slugify("The Strokes - Under Cover of Darkness") ==
             "the-strokes-under-cover-of-darkness"

    assert Slugy.slugify("Keep the hyphen: build-up") == "keep-the-hyphen-build-up"
  end
end
