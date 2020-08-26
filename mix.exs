defmodule ExModem.MixProject do
  use Mix.Project

  @app :ex_modem
  @version "0.3.0"
  @all_targets [:custom_rpi0]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.10",
      archives: [nerves_bootstrap: "~> 1.8"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      aliases: [loadconfig: [&bootstrap/1]],
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ExModem.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Deps for all targets
      {:nerves, "~> 1.6", runtime: false},
      {:shoehorn, "~> 0.6"},
      {:ring_logger, "~> 0.6"},
      {:toolshed, "~> 0.2"},

      # Deps for all targets except :host
      {:nerves_runtime, "~> 0.6", targets: @all_targets},
      {:nerves_pack, "~> 0.3.0", targets: @all_targets},
      #      {:nerves_runtime_shell, "~> 0.1.0", targets: @all_targets},
      {:busybox, "~> 0.1.3", targets: @all_targets},
      {:vintage_net_mobile, "~> 0.8", targets: @all_targets},
      #      {:vintage_net_direct, "~> 0.8.0", targets: @all_targets},
      {:circuits_uart, "~> 1.3", targets: @all_targets},
      {:elixircom, "~> 0.2.0", targets: @all_targets},
      #      {:elixir_ale, "~>1.2.1", targets: @all_targets},
      {:circuits_gpio, "~> 0.4", targets: @all_targets},
      {:nerves_time, "~> 0.2", targets: @all_targets},
      {:nerves_firmware_ssh, "~> 0.2", targets: @all_targets},

      # Deps for specific targets
#      {:nerves_system_rpi0, "~> 1.11", runtime: false, targets: :rpi0},
      # nerves: [compile: true]}
      {:custom_rpi0, path: "../custom_rpi0", runtime: false, targets: :custom_rpi0}
    ]
  end

  def release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod
    ]
  end
end
