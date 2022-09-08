Code.eval_file("mess.exs")
defmodule Bonfire.MixProject do
  use Mix.Project

  @config [ # TODO: put these in ENV or an external writeable config file similar to deps.*
      version: "0.3.4-beta.25", # note that the flavour will automatically be added where the dash appears
      elixir: "~> 1.13",
      default_flavour: "classic",
      logo: "assets/static/images/bonfire-icon.png",
      docs: [
        "README.md",
        "docs/HACKING.md",
        "docs/DEPLOY.md",
        "docs/ARCHITECTURE.md",
        "docs/BONFIRE-FLAVOURED-ELIXIR.md",
        "docs/DATABASE.md",
        "docs/BOUNDARIES.md",
        "docs/GRAPHQL.md",
        "docs/MRF.md",
        "docs/CHANGELOG.md",
        "docs/CHANGELOG-autogenerated.md",
      ],
      deps_prefixes: [
        docs: ["bonfire", "pointers", "paginator", "ecto_shorts", "ecto_sparkles", "absinthe_client", "activity_pub", "arrows", "ecto_materialized_path", "flexto", "grumble", "linkify", "verbs", "voodoo", "waffle", "zest"],
        test: ["bonfire", "pointers", "paginator", "ecto_shorts", "ecto_sparkles", "activity_pub", "linkify", "fetch_favicon"],
        data: ["bonfire_data_", "bonfire_data_edges", "pointers", "bonfire_boundaries", "bonfire_tag", "bonfire_classify", "bonfire_geolocate", "bonfire_quantify", "bonfire_valueflows"],
        api: ["bonfire_me", "bonfire_social", "bonfire_tag", "bonfire_classify", "bonfire_geolocate", "bonfire_valueflows"],
        localise: ["bonfire"],
        localise_self: []
      ]
    ]

  def project do
    [
      app: :bonfire,
      version: version(),
      elixir: @config[:elixir],
      elixirc_options: [debug_info: true, docs: true],
      elixirc_paths: elixirc_paths(Mix.env()),
      test_paths: test_paths(),
      test_deps: deps(:test),
      compilers: compilers(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      multirepo_deps: deps(:bonfire),
      in_multirepo_fn: &in_multirepo?/1,
      multirepo_recompile_fn: &deps_recompile/0,
      config_path: config_path("config.exs"),
      releases: [
        bonfire: [
          runtime_config_path: config_path("runtime.exs"),
          strip_beams: false # to enable debugging
        ],
      ],
      source_url: "https://github.com/bonfire-networks/bonfire-app",
      homepage_url: "https://bonfirenetworks.org",
      docs: [
        # The first page to display from the docs
        main: "readme",
        logo: @config[:logo],
        output: "docs/exdoc",
        source_url_pattern: &source_url_pattern/2,
        # extra pages to include
        extras: readme_paths(),
        # extra apps to include in module docs
        source_beam: beam_paths(:docs),
        deps: doc_deps(),
        groups_for_extras: [ # Note: first match wins
          "Guides": Path.wildcard("docs/*"),
          "Flavours of Bonfire": Path.wildcard("flavours/*/*"),
          "Data schemas": Path.wildcard("{deps,forks}/bonfire_data_*/*"),
          "UI extensions": Path.wildcard("{deps,forks}/bonfire_ui_*/*"),
          "Bonfire utilities": ["bonfire_api_graphql", "bonfire_boundaries", "bonfire_common", "bonfire_ecto", "bonfire_epics", "bonfire_fail", "bonfire_files", "bonfire_mailer"] |> Enum.flat_map(&Path.wildcard("{deps,forks}/#{&1}/*")),
          "Feature extensions": Path.wildcard("{deps,forks}/bonfire_*/*"),
          "Other utilities": Path.wildcard("{deps,forks}/*/*"),
          "Dependencies": Path.wildcard("docs/DEPENDENCIES/*"),
        ],
        groups_for_modules: [
          "Data schemas": ~r/^Bonfire.Data.?/,
          "UI extensions": ~r/^Bonfire.UI.?/,
          "Bonfire utilities": [~r/^Bonfire.API?/, ~r/^Bonfire.GraphQL?/, ~r/^Bonfire.Web?/, ~r/^Bonfire.Boundaries?/, ~r/^Bonfire.Common?/, ~r/^Bonfire.Ecto?/, ~r/^Bonfire.Epics?/, ~r/^Bonfire.Fail?/, ~r/^Bonfire.Files?/, ~r/^Bonfire.Mailer?/],
          "Feature extensions": [~r/^Bonfire.?/, ~r/^ValueFlows.?/],
          "Utilities": ~r/.?/,
        ],
        nest_modules_by_prefix: [
          Bonfire.Data,
          # Bonfire.UI,
          Bonfire,
          ValueFlows
        ]
      ],
    ]

  end

  def application do
    [
      mod: {Bonfire.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon, :ssl, :bamboo, :bamboo_smtp]
    ]
  end

  defp aliases do
    [
      "hex.setup": ["local.hex --force"],
      "rebar.setup": ["local.rebar --force"],
      "assets.build": [
        "cmd cd ./assets && yarn build",
      ],
      "bonfire.seeds": [
        # "phil_columns.seed",
      ],
      "bonfire.deps.update": ["deps.update " <> deps_to_update()],
      "bonfire.deps.clean": ["deps.clean " <> deps_to_clean(:localise) <> " --build"],
      "bonfire.deps.clean.data": ["deps.clean " <> deps_to_clean(:data) <> " --build"],
      "bonfire.deps.clean.api": ["deps.clean " <> deps_to_clean(:api) <> " --build"],
      "bonfire.deps.recompile": ["deps.compile " <> deps_to_update() <> " --force"],
      "bonfire.deps": ["bonfire.deps.update", "bonfire.deps.clean.data"],
      "ecto.seeds": [
        "run #{flavour_path()}/repo/seeds.exs"
        ],
      "js.deps.get": ["cmd make js.deps.get"],
      "js.deps.update": ["cmd cd assets && yarn update"],
      setup: ["hex.setup", "rebar.setup", "deps.get", "bonfire.deps.clean.data", "ecto.setup"],
      updates: ["deps.get", "bonfire.deps"],
      upgrade: ["updates", "ecto.migrate"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.migrate": ["ecto.migrate", "bonfire.seeds"],
      "ecto.reset": ["ecto.drop --force", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
    ]
  end

  def deps() do
    Mess.deps(mess_sources(), [
      ## password hashing - builtin vs nif
      {:pbkdf2_elixir, "~> 2.0", only: [:dev, :test]},
      {:argon2_elixir, "~> 3.0", only: [:prod]},

      # error reporting
      {:sentry, "~> 8.0", only: [:dev, :prod]},

      ## dev conveniences
      # {:dbg, "~> 1.0", only: [:dev, :test]},
      {:phoenix_live_reload, "~> 1.3", only: :dev},
      {:exsync, "~> 0.2", only: :dev},
      {:mix_unused, "~> 0.4", only: :dev},
      {:ex_doc, "~> 0.28.3", only: [:dev, :test], runtime: false},
      {:ecto_erd, "~> 0.4", only: :dev},
      # {:ecto_dev_logger, "~> 0.4", only: :dev},
      {:flame_on, "~> 0.5", only: :dev}, # flame graphs in live_dashboard
      {:pseudo_gettext, git: "https://github.com/tmbb/pseudo_gettext", only: :dev},
      {:periscope, "~> 0.4", only: :dev},
      # {:changelog, "~> 0.1", only: [:dev, :test], runtime: false}, # retrieve changelogs of latest dependency versions
      {:versioce, "~> 1.1.2", only: :dev}, # changelog generation
      {:git_cli, "~> 0.3.0", only: :dev}, # needed for changelog generation
      {:archeometer, git: "https://gitlab.com/mayel/archeometer", only: [:dev, :test]}, # "~> 0.1.0"
      {:ex_sqlean, "~> 0.8.7", only: [:dev, :test]}, # Precompiled native SQLITE (used for archeometer)

      # tests
      {:floki, ">= 0.0.0", only: [:dev, :test]},
      {:ex_machina, "~> 2.4", only: :test},
      {:mock, "~> 0.3", only: :test},
      {:mox, "~> 1.0", only: :test},
      {:zest, "~> 0.1.0"},
      {:grumble, "~> 0.1.3", only: [:test], override: true},
      {:mix_test_watch, "~> 1.0", only: :test, runtime: false},
      {:mix_test_interactive, "~> 1.2", only: :test, runtime: false},
      {:ex_unit_notifier, "~> 1.0", only: :test},
      {:wallaby, "~> 0.30", runtime: false, only: :test},
      # {:bypass, "~> 2.1", only: :test}, # used in furlex

      # Benchmarking utilities
      {:benchee, "~> 1.1", only: :dev},
      {:benchee_html, "~> 1.0", only: :dev},

      # list dependencies & licenses
      {:licensir, only: :dev, runtime: false,
        git: "https://github.com/bonfire-networks/licensir", branch: "main",
        # path: "./forks/licensir"
      },

      # security auditing
      # {:mix_audit, "~> 0.1", only: [:dev], runtime: false}
      {:sobelow, "~> 0.8", only: :dev}
      ]
    )

  end

  defp compilers(:dev) do
    [:unused] ++ compilers(nil)
  end
  defp compilers(_) do
    [:phoenix] ++ Mix.compilers()
  end

  def catalogues(_env) do
    [
      "deps/surface/priv/catalogue",
      dep_path("bonfire_ui_social")<>"/priv/catalogue"
    ]
  end

  def deps(deps \\ deps(), deps_subtype)
  def deps(deps, :bonfire) do
    deps_prefixes = multirepo_prefixes()
    Enum.filter(deps, &in_multirepo?(&1, deps_prefixes))
  end
  def deps(deps, deps_subtype) when is_atom(deps_subtype), do:
    Enum.filter(deps, &include_dep?(deps_subtype, &1, @config[:deps_prefixes][deps_subtype]))

  def multirepo_prefixes(), do: Enum.flat_map(@config[:deps_prefixes], fn {_, list} -> list end) |> Enum.uniq()
  def in_multirepo?(dep, deps_prefixes \\ multirepo_prefixes()), do: include_dep?(:bonfire, dep, deps_prefixes)

  def deps_recompile(deps \\ deps_for(:bonfire)), do: Mix.Task.run("bonfire.dep.compile", ["--force"] ++ List.wrap(deps))

  def flavour_path(), do:
    System.get_env("FLAVOUR_PATH", "flavours/"<>flavour())

  def flavour(), do:
    System.get_env("FLAVOUR", @config[:default_flavour])

  def config_path(flavour_path \\ flavour_path(), filename),
    do: Path.expand(Path.join([flavour_path, "config", filename]))

  def forks_path(), do: System.get_env("FORKS_PATH", "forks/")

  defp mess_sources() do
    mess_sources(System.get_env("WITH_FORKS","1"))
    |> Enum.map(fn {k,v} -> {k, config_path(v)} end)
  end

  defp mess_sources("0"),  do: [git: "deps.git", hex: "deps.hex"]
  defp mess_sources(_),    do: [path: "deps.path", git: "deps.git", hex: "deps.hex"]

  def deps_to_clean(type) do
    deps(type)
    |> deps_names()
  end

  def deps_to_update() do
    deps(:update)
    |> deps_names()
    |> IO.inspect(label: "Running Bonfire #{version()} with configuration from #{flavour_path()} in #{Mix.env()} environment. You can run `mix bonfire.deps.update` to update these extensions and dependencies")
  end

  # Specifies which paths to include in docs

  def beam_paths(type \\ :all) do
    build = Mix.Project.build_path()
    ([:bonfire] ++ deps(type))
    |> Enum.map(&beam_path(&1, build))
  end
  defp beam_path(app, build), do: Path.join([build, "lib", dep_name(app), "ebin"])

  def readme_paths(), do: @config[:docs]
                          ++ Enum.map(Path.wildcard("flavours/*/README.md"), &flavour_readme/1)
                          ++ Enum.map(Path.wildcard("docs/DEPENDENCIES/*.md"), &flavour_deps_doc/1)
                          ++ Enum.flat_map(deps(:docs), &readme_path/1)

  defp readme_path(dep) when not is_nil(dep), do: dep_paths(dep, "README.md") |> List.first |> readme_path(dep)
  defp readme_path(path, dep) when not is_nil(path), do: [{path |> String.to_atom, [filename: "extension-"<>dep_name(dep)]}]
  defp readme_path(_, _), do: []

  def flavour_readme(path), do: {path |> String.to_atom, [filename: path |> String.split("/") |> Enum.at(1)]}
  def flavour_deps_doc(path), do: {path |> String.to_atom, [title: path |> String.split("/") |> Enum.at(2) |> String.slice(0..-4) |> String.capitalize(), filename: path |> String.split("/") |> Enum.at(2) |> String.slice(0..-4) |> then(&"deps-#{&1}")]}

  defp doc_deps(), do: deps(:docs) |> Enum.map(&doc_dep/1) #[plug: "https://myserver/plug/"]
  defp doc_dep(dep), do: {elem(dep, 0), "./"}

  def source_url_pattern("deps/"<>_=path, line), do: bonfire_ext_pattern(path, line)
  def source_url_pattern("forks/"<>_=path, line), do: bonfire_ext_pattern(path, line)
  def source_url_pattern(path, line), do: bonfire_app_pattern(path, line)

  defp bonfire_ext_pattern(path, line), do: bonfire_ext_pattern(path |> String.split("/") |> Enum.at(1), path |> String.split("/") |> Enum.slice(2..1000) |> Enum.join("/"), line)
  defp bonfire_ext_pattern(dep, path, line), do: bonfire_app_pattern("https://github.com/bonfire-networks/#{dep}/blob/main/%{path}#L%{line}", path, line)

  defp bonfire_app_pattern(path, line), do: bonfire_app_pattern("https://github.com/bonfire-networks/bonfire-app/blob/main/%{path}#L%{line}", path, line)

  defp bonfire_app_pattern(pattern, path, line), do: pattern |> String.replace("%{path}", "#{path}") |> String.replace("%{line}", "#{line}")

  # Specifies which paths to include when running tests
  defp test_paths(), do: ["test" | Enum.flat_map(deps(:test), &dep_paths(&1, "test"))]

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support" | Enum.flat_map(deps(:test), &dep_paths(&1, "test/support"))]
  defp elixirc_paths(env), do: ["lib"] ++ catalogues(env)

  defp include_dep?(type, dep, deps_prefixes \\ nil)
  defp include_dep?(:update, dep, _deps_prefixes) when is_tuple(dep), do: unpinned_git_dep?(dep)
  # defp include_dep?(:docs = type, dep, deps_prefixes), do: String.starts_with?(dep_name(dep), deps_prefixes || @config[:deps_prefixes][type]) || git_dep?(dep)
  defp include_dep?(type, dep, deps_prefixes), do: String.starts_with?(dep_name(dep), deps_prefixes || @config[:deps_prefixes][type])

  defp git_dep?(dep) do
    spec = elem(dep, 1)
    is_list(spec) && spec[:git]
  end

  defp unpinned_git_dep?(dep) do
    spec = elem(dep, 1)
    is_list(spec) && spec[:git] && !spec[:commit]
  end

  defp dep_name(dep) when is_tuple(dep), do: elem(dep, 0) |> dep_name()
  defp dep_name(dep) when is_atom(dep), do: Atom.to_string(dep)
  defp dep_name(dep) when is_binary(dep), do: dep

  def deps_names(deps) do
    deps
    |> Enum.map(&dep_name/1)
    |> Enum.join(" ")
  end

  def deps_for(type) do
    deps(type)
    |> Enum.map(&dep_name/1)
  end

  defp dep_path(dep) when is_binary(dep) do
    path_if_exists(forks_path()<>dep)
    || path_if_exists(Mix.Project.deps_path() <> "/" <> dep |> Path.expand(File.cwd!))
    || "."
  end

  defp dep_path(dep) do
    spec = elem(dep, 1)

    path = if is_list(spec) && spec[:path],
      do: spec[:path],
      else: Mix.Project.deps_path() <> "/" <> dep_name(dep) |> Path.expand(File.cwd!)

    path_if_exists(path)
  end

  defp path_if_exists(path), do: if File.exists?(path), do: path

  defp dep_paths(dep, extra) when is_list(extra), do: Enum.flat_map(extra, &dep_paths(dep, &1))
  defp dep_paths(dep, extra) when is_binary(extra) do
    dep_path = dep_path(dep)
    if dep_path do
      path = Path.join(dep_path, extra) |> path_if_exists()
      if path, do: [path], else: []
    else
      []
    end
  end

  def version do
    @config[:version]
      |> String.split("-", parts: 2)
      |> List.insert_at(1, flavour())
      |> Enum.join("-")
  end

end