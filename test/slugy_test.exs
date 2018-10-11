defmodule SlugyTest do
  use ExUnit.Case
  doctest Slugy

  test "greets the world" do
    assert Slugy.hello() == :world
  end
end
