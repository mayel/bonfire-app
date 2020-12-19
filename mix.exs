Code.eval_file("mess.exs")
defmodule Bonfire.MixProject do

  use Mix.Project

  @bonfire_data_deps [
    "pointers",
    "bonfire_data_access_control",
    "bonfire_data_identity",
    "bonfire_data_social",
  ]

  @bonfire_deps_to_test [
    "bonfire_notifications",
  ]

  @bonfire_all_deps @bonfire_data_deps ++ @bonfire_deps_to_test

  def project do
    [
      app: :bonfire,
      version: "0.1.0",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      test_paths: ["test"] ++ existing_lib_paths(@bonfire_deps_to_test, "test"),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: Mess.deps [
        {:dbg, "~> 1.0", only: [:dev, :test]},
        # reload when a local code file is modified
        {:phoenix_live_reload, "~> 1.2", only: :dev},
        # reload when a locally forked dependency is modified
        {:exsync, "~> 0.2", only: :dev},
        # for tests
        {:mox, "~> 0.4.0", only: [:dev, :test]},
        {:floki, ">= 0.0.0", only: [:dev, :test]},
      ]
    ]
  end

  def application do
    [
      mod: {Bonfire.Application, []},
      extra_applications: [:logger, :runtime_tools, :ssl, :bamboo, :bamboo_smtp]
    ]
  end


  defp elixirc_paths(:test), do: ["lib", "test/support"] ++ existing_lib_paths(@bonfire_deps_to_test, "test/support")
  defp elixirc_paths(_), do: ["lib"]

  @bonfire_data_deps_str @bonfire_data_deps |> Enum.join(" ")

  defp aliases do
    [
      "hex.setup": ["local.hex --force"],
      "rebar.setup": ["local.rebar --force"],
      "js.deps.get": ["cmd npm install --prefix assets"],
      "js.deps.update": ["cmd npm update --prefix assets"],
      "ecto.seeds": ["run priv/repo/seeds.exs"],
      "bonfire.deps.update": ["deps.update #{@bonfire_data_deps_str}"],
      "bonfire.deps.clean": ["deps.clean #{@bonfire_data_deps_str} --build"],
      "bonfire.deps": ["bonfire.deps.update", "bonfire.deps.clean"],
      setup: ["hex.setup", "rebar.setup", "deps.get", "bonfire.deps.clean", "ecto.setup", "js.deps.get"],
      updates: ["deps.get", "bonfire.deps", "ecto.migrate", "js.deps.get"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "ecto.seeds"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  #TODO: move to mess?

  defp existing_paths(list) do
    Enum.filter(list, & File.exists?(&1))
  end

  defp existing_lib_paths(list, path) do
    Enum.map(list, fn lib -> "./forks/"<>lib<>"/"<>path end)
    |> existing_paths()
  end


end
