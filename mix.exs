defmodule DiscordCms.MixProject do
  use Mix.Project

  def project do
    [
      app: :discord_cms,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {DiscordCms.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bandit, "~> 1.0"},
      {:nostrum, "~> 0.9"},
      {:httpoison, "~> 2.0"},
      {:poison, "~> 5.0"},
      {:earmark, "~> 1.4"},
      {:tailwind, "~> 0.2", only: :dev}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
