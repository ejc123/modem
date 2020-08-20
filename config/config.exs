use Mix.Config

config :ex_modem, target: Mix.target()

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

config :nerves, source_date_epoch: "1595447983"

config :logger, backends: [RingLogger], level: :info

# node_name = if Mix.env() != :prod, do: "exmodem"

if Mix.target() != :host do
  import_config "target.exs"
end
