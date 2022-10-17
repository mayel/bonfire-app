import Config

# Important: indicate date of last release, to generate a changelog for issues closed since then
changelog_issues_closed_after = "2022-08-30"

config :bonfire, Bonfire.Common.Repo,
  # Note: you can run `Bonfire.Common.Config.put(:experimental_features_enabled, true)` to enable these in prod too
  experimental_features_enabled: true,
  database: System.get_env("POSTGRES_DB", "bonfire_dev"),
  # show_sensitive_data_on_connection_error: true,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  # EctoSparkles does the logging instead
  log: false

local_deps = Mess.deps([path: Path.relative_to_cwd("config/deps.path")], [])
local_dep_names = Enum.map(local_deps, &elem(&1, 0))
dep_paths = Enum.map(local_deps, &(Keyword.fetch!(elem(&1, 1), :path) <> "/lib"))
watch_paths = dep_paths ++ ["lib/"] ++ ["priv/static/"]

IO.puts("Watching these deps for code reloading: #{inspect(local_dep_names)}")

config :phoenix_live_reload,
  # watch the app's lib/ dir + the dep/lib/ dir of every locally-cloned dep
  dirs: watch_paths

# filename patterns that should trigger page reloads (only within the above dirs)
patterns = [
  ~r"^priv/static/.*(js|css|png|jpeg|jpg|gif|svg|webp)$",
  # ~r"^priv/gettext/.*(po)$",
  ~r"(_live|_live_handler|live_handlers|routes)\.ex$",
  ~r{(views|templates|pages|components)/.*(ex)$},
  ~r".*(heex|leex|sface)$",
  ~r"priv/catalogue/.*(ex)$"
]

IO.puts("Watching these filenames for live reloading in the browser: #{inspect(patterns)}")

# Watch static and templates for browser reloading.
config :bonfire, Bonfire.Web.Endpoint,
  server: true,
  debug_errors: true,
  check_origin: false,
  code_reloader: true,
  reloadable_apps: [:bonfire] ++ local_dep_names,
  watchers: [
    yarn: [
      "watch.js",
      cd: Path.expand("assets", File.cwd!())
    ],
    yarn: [
      "watch.css",
      cd: Path.expand("assets", File.cwd!())
    ],
    yarn: [
      "watch.assets",
      cd: Path.expand("assets", File.cwd!())
    ]
  ],
  live_reload: [
    patterns: patterns
  ]

config :bonfire, Bonfire.Web.Endpoint, phoenix_profiler: [server: Bonfire.Web.Profiler]

config :logger, :console,
  level: :debug,
  # truncate: :infinity,
  # Do not include metadata or timestamps
  format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 30

config :phoenix, :plug_init_mode, :runtime

config :exsync,
  src_monitor: true,
  reload_timeout: 75,
  # addition_dirs: ["/forks"],
  extra_extensions: [".leex", ".heex", ".js", ".css", ".sface"]

config :versioce, :changelog,
  # Or your own datagrabber module
  datagrabber: Versioce.Changelog.DataGrabber.Git,
  # Or your own formatter module
  formatter: Versioce.Changelog.Formatter.Keepachangelog

config :versioce, :changelog,
  closed_after: changelog_issues_closed_after,
  changelog_file: "docs/CHANGELOG-autogenerated.md",
  datagrabber: Bonfire.Common.Changelog.Github.DataGrabber,
  anchors: %{
    added: ["Feature"],
    changed: ["Improvement", "UI/UX", "Refactor"],
    deprecated: ["[DEP]"],
    removed: ["[REM]"],
    fixed: ["Bug"],
    security: ["Security", "Safety"]
  }
