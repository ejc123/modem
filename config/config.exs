import Config

Application.start(:nerves_bootstrap)

config :ex_modem, target: Mix.target()

config :nerves, :firmware,
  rootfs_overlay: "rootfs_overlay",
  provisioning: "config/provisioning.conf"

config :nerves, source_date_epoch: "1595447983"

config :nerves, rpi_v2_ack: true

config :logger,
  backends: [{LoggerFileBackend, :info_log}, {LoggerFileBackend, :error_log}, RingLogger],
  level: :info

config :logger, :info_log,
  path: "/root/info.log",
  level: :info

config :logger, :error_log,
  path: "/root/error.log",
  level: :error

if Mix.target() != :host do
  import_config "target.exs"
end
