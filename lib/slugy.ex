defmodule Slugy do
  @doc """
  Returns a downcased dashed string.

  ## Examples

      iex> Slugy.slugify("Hey ow lets go")
      "hey-ow-lets-go"
  """
  def slugify(str) do
    str
    |> String.normalize(:nfd)
    |> String.replace(~r/[^A-z\s\d]/u, "")
    |> String.replace(~r/\s/, "-")
    |> String.downcase()
  end
end
