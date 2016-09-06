defmodule Eidetic.Mixfile do
  use Mix.Project

  def project do
    [
      app: :eidetic,
      version: "0.1.0",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
        applications: [
            :logger
        ]
    ]
  end

  defp deps do
    [
        {:espec, "~> 1.0.1", only: :test},
    ]
  end
end
