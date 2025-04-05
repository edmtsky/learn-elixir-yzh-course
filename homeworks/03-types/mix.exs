defmodule Project.MixProject do
  use Mix.Project

  def project do
    [
      app: :app,
      version: "0.1.0",
      elixir: "~> 1.16",
      elixirc_paths: ["./"],
      test_paths: ["./"],
      start_permanent: Mix.env() == :prod,
      deps: []
    ]
  end

  def application do [] end
end
