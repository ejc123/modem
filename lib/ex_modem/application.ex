defmodule ExModem.Application do
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define children
    children = [
      ExModem.Board,
      ExModem.Listener,
      ExModem.GPS,
    ]

    opts = [strategy: :one_for_one, name: ExModem.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
