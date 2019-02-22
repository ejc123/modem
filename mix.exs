defmodule ExModem.MixProject do
  use Mix.Project

  @all_targets [:rpi0, :rpi3, :rpi]

  def project do
    [
      app: :ex_modem,
      version: "0.2.0",
      elixir: "~> 1.8",
      archives: [nerves_bootstrap: "~> 1.4"],
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.target() != :host,
      aliases: [loadconfig: [&bootstrap/1]],
      deps: deps()
    ]
  end

  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [mod: {ExModem.Application, []}, extra_applications: [:logger, :runtime_tools]]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Deps for all targets
      {:nerves, "~> 1.4", runtime: false},
      {:shoehorn, "~> 0.4"},
      {:ring_logger, "~> 0.6"},
      {:toolshed, "~> 0.2"},

      # Deps for all targets except :host
      {:nerves_runtime, "~> 0.6", targets: @all_targets},
#      {:nerves_runtime_shell, "~> 0.1.0", targets: @all_targets},
      {:nerves_uart, "~> 1.2.1", targets: @all_targets},
      {:elixir_ale, "~>1.2.1", targets: @all_targets},
      {:nerves_init_gadget, "~> 0.6", targets: @all_targets},

      # Deps for specific targets
      {:nerves_system_rpi, "~> 1.6", runtime: false, targets: :rpi},
      {:nerves_system_rpi0, "~> 1.6", runtime: false, targets: :rpi0},
      {:nerves_system_rpi3a, "~> 1.6", runtime: false, targets: :rpi3a},
    ]
  end
end
