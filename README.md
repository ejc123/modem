# ExModem

This library is an interface to a SIM868-based modem

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_modem` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_modem, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_modem](https://hexdocs.pm/ex_modem).


To install nerves_bootstrap:

```shell
mix archive.install hex nerves_bootstrap
```

Start minicom:

```shell
minicom -D /dev/ttyACM0 -b 115200 -C logFile
```

