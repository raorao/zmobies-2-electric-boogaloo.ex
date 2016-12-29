defmodule Simulator.Mixfile do
  use Mix.Project

  def project do
    [app: :simulator,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :gproc],
     mod: {Simulator, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      { :uuid, "~> 1.1" },
      { :gproc, "~> 0.6.1" },
      {:dialyxir, "~> 0.4", only: [:dev], runtime: false}
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end
end