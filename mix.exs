defmodule ExModem.MixProject do
  use Mix.Project

  @app :ex_modem
  @version "0.3.0"
  @all_targets [:modem_rpi0, :rpi0]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.10",
      archives: [nerves_bootstrap: "~> 1.10"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ExModem.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specify target specific application configurations
  # It is common that the application start function will start and supervise
  # applications which could cause the host to fail. Because of this, we only
  # invoke TempSensor.start/2 when running on a target.
  def application("host") do
    [extra_applications: [:logger]]
  end

  def application(_target) do
    [
      mod: {ExModem.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Deps for all targets
      {:nerves, "~> 1.7", runtime: false},
      {:shoehorn, "~> 0.7"},
      {:ring_logger, "~> 0.8"},
      {:toolshed, "~> 0.2"},
      {:logger_file_backend, "~> 0.0.12"},
      # Deps for all targets except :host
      {:nerves_runtime, "~> 0.11", targets: @all_targets},
      {:nerves_pack, "~> 0.6", targets: @all_targets},
      {:busybox, "~> 0.1.5", targets: @all_targets},
#      {:vintage_net_mobile, "~> 0.8", targets: @all_targets},
      {:vintage_net_mobile, path: "../vintage_net_mobile", targets: @all_targets},
      {:circuits_uart, "~> 1.4", targets: @all_targets},
      {:elixircom, "~> 0.2", targets: @all_targets},
      {:circuits_gpio, "~> 0.4", targets: @all_targets},
      {:nerves_time, "~> 0.4", targets: @all_targets},

      # Deps for specific targets
#      {:nerves_system_rpi0, "~> 1.21.1", runtime: false, targets: :rpi0},
#      {:modem_rpi0, path: "../modem_rpi0", runtime: false, targets: :modem_rpi0}
#      {:modem_rpi0, path: "../modem_rpi0", runtime: false, targets: :modem_rpi0},
      {:modem_rpi0, github: "ejc123/modem_rpi0", tag: "v1.21.1-local", runtime: false, targets: :modem_rpi0},
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
