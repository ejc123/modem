use Mix.Config

config :nerves, rpi_v2_ack: true

# Use shoehorn to start the main applications.  See the shoehorn
# docs for separating out critical OTP applications such as those
# involved with firmware updates.

config :shoehorn,
  init: [:nerves_runtime, :nerves_pack],
  app: Mix.Project.config()[:app]

config :nerves_runtime, :kernel, use_system_registry: false

config :nerves,
  erlinit: [
    hostname_pattern: "nerves-%s"
  ]

# Authorize the device to receive firmware using public key.

keys =
  [
    Path.join([System.user_home!(), ".ssh", "id_rsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_nerves_ecdsa.pub"])
  ]
  |> Enum.filter(&File.exists?/1)

if keys == [],
  do:
    Mix.raise("""
    No SSH public keys found in ~/.ssh. An ssh authorized key is needed to
    log into the Nerves device and update firmware on it using ssh.
    See your project's config.exs for this error message.
    """)

config :nerves_firmware_ssh,
  authorized_keys: Enum.map(keys, &File.read!/1)

config :vintage_net, regulatory_domain: "US",
  config: [
    {"usb0", %{type: VintageNetDirect}},
    {"wlan0", %{type: VintageNetWiFi,
      vintage_net_wifi: %{
        key_mgmt: :wpa_psk,
        mode: :client,
        ssid: System.get_env("NERVES_NETWORK_SSID"),
        psk:  System.get_env("NERVES_NETWORK_PSK"),
      },
      ipv4: %{method: :dhcp}
      }
    }
  ]


config :mdns_lite,
  host: [:hostname, "nerves"],
  ttl: 120,

  services: [
    %{
      name: "SSH Remote Login Protocol",
      protocol: "ssh",
      transport: "tcp",
      port: 22
    },
    %{
      name: "Secure File Transfer Protocol over SSH",
      protocol: "sftp-ssh",
      transport: "tcp",
      port: 22
    },
    %{
      name: "Erlang Port Mapper Daemon",
      protocol: "epmd",
      transport: "tcp",
      port: 4369
    }
  ]

