defmodule Eidetic.Mixfile do
  use Mix.Project

  def project do
    [ app: :eidetic,
      version: "0.0.1",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps()
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
end

