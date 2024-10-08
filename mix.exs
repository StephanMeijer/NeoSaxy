defmodule NeoSaxy.MixProject do
  use Mix.Project

  @source_url "https://github.com/StephanMeijer/neo_saxy"
  @version "1.0.2"

  def project() do
    [
      app: :neo_saxy,
      version: @version,
      elixir: "~> 1.12",
      name: "NeoSaxy",
      consolidate_protocols: Mix.env() != :test,
      deps: deps(),
      package: package(),
      docs: docs()
    ]
  end

  def application(), do: []

  defp package() do
    [
      description:
        "NeoSaxy is an XML parser and encoder in Elixir that focuses on speed " <>
          "and standard compliance.",
      maintainers: ["Stephan Meijer"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "https://hexdocs.pm/neo_saxy/changelog.html"
      }
    ]
  end

  defp deps() do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:stream_data, "~> 1.0", only: [:dev, :test]}
    ]
  end

  defp docs() do
    [
      extras: [
        "CHANGELOG.md",
        {:"LICENSE.md", [title: "License"]},
        "README.md",
        "guides/getting-started-with-sax.md"
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      assets: "assets",
      formatters: ["html"],
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end
end
