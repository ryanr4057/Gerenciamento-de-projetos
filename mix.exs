defmodule Proj.MixProject do
  use Mix.Project

  def project do
    [
      app: :proj,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Proj.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:ecto_sqlite3, "~> 0.10"},
      {:assoc, "~> 0.2.3"},
      {:dialyxir, "~> 1.3", runtime: false},
      {:nimble_csv, "~> 1.2"}
    ]
  end
end
