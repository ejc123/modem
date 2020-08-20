defmodule ExModem.Board do
  use GenServer

  alias ExModem.GPS

  @moduledoc """
    Set up Modem/GPS board
  """


  # Durations are in milliseconds
  @on_duration 3000

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl GenServer
  def init(_state) do
    tty = "ttyAMA0"
    options = [speed: 115_200, active: true, framing: {Circuits.UART.Framing.Line, separator: "\r\n"}, id: :pid]
    {uart_pid, gpio, gps_pid} = start(tty, options)
    {:ok, {uart_pid, gpio, gps_pid, options}}
  end

  # GenServer callbacks
  @impl GenServer
  def handle_call({:start, _tty, _options}, _from, state) do
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:start_gps, {uart_pid, gpio, gps_pid} = state) when gps_pid == 0 do
    Logger.debug("***start_gps: #{inspect(state)}")
    {:noreply, {uart_pid, gpio, GPS.start(uart_pid)}}
  end

  @impl GenServer
  def handle_info(:start_gps, {uart_pid, gpio, gps_pid} = _state) do
    {:noreply, {uart_pid, gpio, gps_pid}}
  end

  @impl GenServer
  def handle_info(:stop_gps, {uart_pid, gpio, gps_pid} = _state) do
    GPS.stop({uart_pid, gps_pid})
    {:noreply, {uart_pid, gpio, 0}}
  end

  @impl GenServer
  def handle_info(msg, state) do
    Logger.info("***circuits: #{inspect(msg)}")
    Logger.debug("***circuits: #{inspect(state)}")
    {:noreply, state}
  end

  # Handle messages from gps UART


  # private functions
  defp start(tty, options) do
    {:ok, gpio} = Circuits.GPIO.open(4, :output)
    toggle_power(gpio)
    :timer.sleep(1500)
    toggle_power(gpio)
    # Pause to let modem reset before we query it
    :timer.sleep(2000)

    Logger.info("***start, gpio_pid: #{inspect(gpio)}")
    {:ok, uart_pid} = Circuits.UART.start_link()
    Logger.info("***start, uart_pid: #{inspect(uart_pid)}")

    :ok =
      Circuits.UART.open(
        uart_pid,
    #    "ttyAMA0",
        tty,
        options)

    #    speed: 115_200,
    #    active: true,
    #    framing: {Circuits.UART.Framing.Line, separator: "\r\n"},
    #    id: :pid
    #  )

    Logger.debug("***UART open")
    reset(uart_pid)
    {uart_pid, gpio, 0}
  end

  # Reset Modem
  defp reset(pid) do
    Circuits.UART.write(pid, "ATZ")
    :timer.sleep(500)
  end

  defp toggle_power(gpio) do
    :ok = Circuits.GPIO.write(gpio, 0)
    :timer.sleep(100)
    :ok = Circuits.GPIO.write(gpio, 1)
    :timer.sleep(100)
    :ok = Circuits.GPIO.write(gpio, 0)
  end
end
