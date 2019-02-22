# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Customize the firmware. Uncomment all or parts of the following
# to add files to the root filesystem or modify the firmware
# archive.

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"
#   fwup_conf: "config/fwup.conf"

config :shoehorn,
  init: [:nerves_runtime, :nerves_init_gadget],
  app: Mix.Project.config()[:app]

# Allows over the air updates via SSH.
config :nerves_firmware_ssh,
  authorized_keys: [
    File.read!(Path.join(System.user_home!(), ".ssh/id_rsa.pub"))
  ]

# Allows for tailing of logs.
config :logger, backends: [RingLogger]

node_name = if Mix.env() != :prod, do: "exmodem"


config :nerves_init_gadget,
  ifname: "usb0",
  address_method: :dhcpd,
  mdns_domain: :hostname,
  node_name: node_name,
  node_host: :ip

# Set a mdns domain and node_name to be able to remsh into the device.
#config :nerves_network, :default,
#  usb0: [
#    ipv4_address_method: :static,
#    ipv4_address: "192.168.24.1",
#    ipv4_subnet_mask: "255.255.0.0",
#    nameservers: ["8.8.8.8"]
#  ]

#  ipv4_address: "192.168.24.1",
#  ipv4_subnet_mask: "255.255.0.0",
#  domain: "test.net",
#  nameservers: ["8.8.8.8"]
#  node_name: :blinky,
#  mdns_domain: "blinky.local"

# for Devices that don't support usb gadget such as raspberry pi 1, 2, and 3.
# address_method: :dhcp,
# ifname: "eth0"

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

# import_config "#{Mix.target()}.exs"
