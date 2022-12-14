defmodule ExModem.Listener do
  use GenServer
  require Logger

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: :listener)

  @impl GenServer
  def init(_state) do
    Logger.debug("Listener Started, PID: #{inspect(self())}")
    {:ok, {-1, false}, {:continue, :start}}
  end

  # Handle messages from UART

  @impl GenServer
  def handle_continue(:start, state) do
    :timer.sleep(500)
    GenServer.cast(:board, :start_listener)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:circuits_uart, _pid, <<_::binary-10>> <> "1,1," <> <<rest::binary>>}, state) do
    Logger.info("***Rec: #{inspect(rest)}")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:circuits_uart, _pid, <<_::binary-10>> <> "1,0," <> <<rest::binary>>}, state) do
    Logger.info("***No Fix: #{inspect(rest)}")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:circuits_uart, _pid, <<_::binary-10>> <> "0," <> <<rest::binary>>}, state) do
    Logger.info("***N/C: #{inspect(rest)}")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(msg, state) do
    Logger.debug("***circuits: #{inspect(msg)}")
    Logger.debug("***circuits: #{inspect(state)}")
    {:noreply, state}
  end
end
