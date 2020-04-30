defmodule Slugy.MixProject do
  use Mix.Project

  def project do
    [
      app: :slugy,
      elixir: "~> 1.7",
      version: "4.0.1",
      start_permanent: Mix.env() == :prod,
      description: "A Phoenix library to generate slug for your schemas",
      elixirc_paths: elixirc_paths(Mix.env()),
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
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:ecto, "~> 3.4.0"}
    ]
  end

  defp package() do
    [
      licenses: ["MIT"],
      maintainers: ["Norberto Oliveira Junior", "Cairo Noleto"],
      files: ~w(lib mix.exs README* LICENSE*),
      links: %{"GitHub" => "https://github.com/norbajunior/slugy"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
