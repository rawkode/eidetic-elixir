defmodule Eidetic.Mixfile do
  use Mix.Project


  def project do
    [ app: :eidetic,
      version: "0.0.1",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env)
    ]
  end

  def application do
    [ extra_applications: [
      :logger
    ]
  ]
  end

  def deps do
    []
  end

  def aliases do
    [ "init": ["local.hex --force", "deps.get"],
      "test": ["init", "test"]
    ]
  end

  defp elixirc_paths(:test),  do: ["lib","examples"]
  defp elixirc_paths(:dev),   do: elixirc_paths(:test)
  defp elixirc_paths(_),      do: []

  defp description do
    """
    An event-sourcing library for Elixir
    """
  end

  defp package do
    [ name: :eidetic,
      files: ["lib", "examples", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["David McKay"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/rawkode/eidetic-elixir"}]
  end
end

