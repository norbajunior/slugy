defmodule Slugy.MixProject do
  use Mix.Project

  def project do
    [
      app: :slugy,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      description: "Is your library to create slug from string.",
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package() do
    [
      licenses: ["MIT"],
      files: ~w(lib mix.exs README* LICENSE*),
      links: %{"GitHub" => "https://github.com/appprova/slugy"},
    ]
  end
end
