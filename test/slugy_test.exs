defmodule SlugyTest do
  use ExUnit.Case

  alias Ecto.Changeset

  defmodule Post do
    use Ecto.Schema

    embedded_schema do
      field(:title, :string)
      field(:slug, :string)
    end
  end

  describe "slugify/2" do
    test "puts generated slug on changeset changes and returns changeset" do
      changeset = Changeset.cast(%Post{}, %{title: "A new post"}, [:title])

      assert %{changes: %{slug: "a-new-post"}} = Slugy.slugify(changeset, :title)
    end

    test "returns changeset when there is no changes to apply" do
      changeset = Changeset.cast(%Post{}, %{}, [:title])

      assert %{changes: %{}} = Slugy.slugify(changeset, :name)
    end
  end

  describe "generate_slug/1" do
    assert Slugy.generate_slug("Hey ow lets go") == "hey-ow-lets-go"
    assert Slugy.generate_slug("Olá, julia") == "ola-julia"
  end
end
