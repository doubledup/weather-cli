defmodule Weather.MixProject do
  use Mix.Project

  def project do
    [
      app: :weather,
      name: "Weather CLI",
      source_url: "https://github.com/doubledup/issues-cli",
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: [
        main_module: Weather
      ]
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
      {:httpoison, "~> 1.4.0"},
    ]
  end
end
