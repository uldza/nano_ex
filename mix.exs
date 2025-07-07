defmodule Nano.MixProject do
  use Mix.Project

  @app :nano
  @project "Nano"

  def project do
    [
      app: @app,
      version: "0.1.0",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      # To configure dialyzer
      dialyzer: [
        flags: ["-Wunmatched_returns", :error_handling, :underspecs],
        plt_add_apps: [:mix]
      ],
      # To set test coverage threshold
      test_coverage: [
        summary: [
          threshold: 80
        ]
      ],
      # Releases configuration
      releases: [
        {@app,
         [
           include_executables_for: [:unix],
           include_erts: true,
           steps: [:assemble, :tar],
           applications: [runtime_tools: :permanent],
           path: "./release"
         ]}
      ],
      docs: docs(),
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Nano.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      {:phoenix, "~> 1.7.21"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.10"},
      {:ecto_sqlite3, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0", override: true},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.5",
       app: false,
       compile: false,
       sparse: "optimized"},
      {:swoosh, "~> 1.5"},
      {:floki, ">= 0.30.0"},
      {:premailex, "~> 0.3.20"},
      {:phoenix_swoosh, "~> 1.2"},
      {:typed_ecto_schema, "~> 0.4.3"},
      {:email_checker, "~> 0.2.4"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"},
      # CORS
      {:cors_plug, "~> 3.0"},
      # Code quality libs
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      # Added libs for web
      {:cachex, "~> 4.0"},
      {:slugify, "~> 1.3"},
      {:html_sanitize_ex, "~> 1.4"},
      {:stripity_stripe, "~> 3.2"},
      # For content parser
      {:earmark, "~> 1.4"},
      {:yaml_elixir, "~> 2.11"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      lint: ["deps.get", "format --check-formatted", "credo"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.seed": ["run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind #{@app}", "esbuild #{@app}"],
      "assets.deploy": [
        "tailwind #{@app} --minify",
        "esbuild #{@app} --minify",
        "phx.digest"
      ]
    ]
  end

  defp docs do
    [
      main: @project,
      extras: ["README.md"]
    ]
  end
end
