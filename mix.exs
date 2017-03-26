defmodule Eidetic.Mixfile do
  use Mix.Project


  def project do
    [ app: :eidetic,
      version: "0.0.2",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      aliases: aliases(),
      description: description(),
      package: package()
    ]
  end

  def application do
    [ extra_applications: [
      :logger
    ]
  ]
  end

  def deps do
    [ {:ex_doc, ">= 0.0.0", only: :dev},
      {:uuid, "~> 1.1"}]
  end

  def aliases do
    [ "init": ["local.hex --force", "deps.get"],
      "test": ["init", "test"]
    ]
  end

  defp description do
    """
    An event-sourcing library for Elixir
    """
  end

  defp package do
    [ name: :eidetic,
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["David McKay"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/rawkode/eidetic-elixir"}]
  end
end

