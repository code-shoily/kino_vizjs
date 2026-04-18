defmodule KinoVizjs.MixProject do
  use Mix.Project

  @version "0.5.0"
  @source_url "https://github.com/code-shoily/kino_vizjs"

  def project do
    [
      app: :kino_vizjs,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "KinoVizjs",
      description:
        "A Kino smart cell and component for rendering GraphViz (DOT) graphs with Viz.js",
      source_url: @source_url,
      homepage_url: @source_url,
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [
      mod: {KinoVizjs, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:kino, "~> 0.14"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      },
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE CHANGELOG.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md"],
      source_url: @source_url,
      source_ref: "v#{@version}"
    ]
  end
end
