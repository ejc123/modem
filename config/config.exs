# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :ex_modem, target: Mix.target()

# Customize the firmware. Uncomment all or parts of the following
# to add files to the root filesystem or modify the firmware
# archive.

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

config :nerves, source_date_epoch: "1595447983"

config :logger, backends: [RingLogger], level: :info

#node_name = if Mix.env() != :prod, do: "exmodem"

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
if Mix.target() != :host do
  import_config "target.exs"
end
