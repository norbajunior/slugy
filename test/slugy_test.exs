defmodule SlugyTest do
  use ExUnit.Case
  doctest Slugy

  test "slugy/1 downcase alphanumerics" do
    assert Slugy.slugify("Hey ow lets go") == "hey-ow-lets-go"
    assert Slugy.slugify("Olá, julia") == "ola-julia"
  end
end
