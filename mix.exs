defmodule PlugRequireHeader.Mixfile do
  use Mix.Project

  def project do
    [
      app: :plug_require_header,
      version: "0.6.0",
      name: "PlugRequireHeader",
      source_url: "https://github.com/DevL/plug_require_header",
      elixir: "~> 1.0",
      deps: deps,
      description: description,
      package: package
    ]
  end

  defp description do
    """
    An Elixir Plug for requiring and extracting a given header.
    """
  end

  defp package do
    [
      contributors: ["Lennart Fridén", "Kim Persson"],
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/DevL/plug_require_header"}
    ]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [
      {:plug, "~> 0.13"},
      {:poison, "~> 1.4"},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.7", only: :dev},
      {:inch_ex, only: :docs}
    ]
  end
end
