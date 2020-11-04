use Mix.Config

config :ex_modem, target: Mix.target()

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

config :nerves, source_date_epoch: "1595447983"

config :nerves, rpi_v2_ack: true

config :logger, backends: [RingLogger], level: :debug

if Mix.target() != :host do
  import_config "target.exs"
end
