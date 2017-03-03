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
    [ applications: [
        :logger
      ]
    ]
  end

  defp deps do
    [ {:ecto, "~> 2.1"},
      {:poison, "~> 3.1"},
      {:espec, "~> 1.0.1", only: :test}
    ]
  end
end

