use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: :dev

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set cookie: :"%Yhz9PK}sX~yZ{.Pi]_6JX?q;l]:,21&cowqufTD^:0}Eq[X_ZcfSi@KrZn%S*?{"
end

environment :prod do
  set cookie: :"%Yhz9PK}sX~yZ{.Pi]_6JX?q;l]:,21&cowqufTD^:0}Eq[X_ZcfSi@KrZn%S*?{"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :ex_modem do
  set version: current_version(:ex_modem)
  plugin Shoehorn
  plugin Nerves
end

