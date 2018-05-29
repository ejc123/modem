defmodule ExModem.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define children
    children = [
      ExModem.GPS
    ]

    opts = [strategy: :one_for_one, name: ExModem.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
