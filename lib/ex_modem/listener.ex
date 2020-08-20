defmodule ExModem.Listener do
  use GenServer
  require Logger

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: {:global, ExModem.Board})

  @impl GenServer
  def init(_state) do
    Logger.debug("Listener Started, PID: #{inspect(self())}")
    {:ok, {-1, false}}
  end
end
