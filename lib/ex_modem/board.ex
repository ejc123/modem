defmodule ExModem.Board do
  use GenServer

  alias ExModem.GPS
  alias Circuits.UART
  alias Circuits.GPIO

  @moduledoc """
    Set up Modem/GPS board
  """
  require Logger

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: {:global, Board})

  @impl GenServer
  def init(_state) do
    tty = "ttyAMA0"

    options = [
      speed: 115_200,
      active: true,
      framing: {UART.Framing.Line, separator: "\r\n"},
      id: :pid
    ]

    {uart_pid, gpio, gps_pid} = start(tty, options)
    {:ok, {uart_pid, gpio, gps_pid}}
  end

  # GenServer callbacks
  @impl GenServer
  def handle_call({:start, _tty, _options}, _from, state) do
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast(:start_gps, {uart_pid, gpio, gps_pid} = state) when gps_pid == 0 do
    Logger.debug("***start_gps: #{inspect(state)}")
    {:noreply, {uart_pid, gpio, GPS.start(uart_pid)}}
  end

  @impl GenServer
  def handle_cast(:start_gps, {uart_pid, gpio, gps_pid} = _state) do
    {:noreply, {uart_pid, gpio, gps_pid}}
  end

  @impl GenServer
  def handle_cast(:stop_gps, {uart_pid, gpio, _gps_pid} = _state) do
    GPS.stop()
    {:noreply, {uart_pid, gpio, 0}}
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
    Logger.info("***circuits: #{inspect(msg)}")
    Logger.debug("***circuits: #{inspect(state)}")
    {:noreply, state}
  end

  # Handle messages from gps UART

  # private functions
  defp start(_tty, _options) do
    {:ok, gpio} = GPIO.open(4, :output)
    Logger.info("***start, Toggle Power")
    toggle_power(gpio)
    :timer.sleep(1500)
    toggle_power(gpio)
    # Pause to let modem reset before we query it
    :timer.sleep(2000)
    Logger.info("***start, Toggle Power")

    Logger.info("***start, gpio_pid: #{inspect(gpio)}")
    {:ok, uart_pid} = UART.start_link()
    Logger.info("***start, uart_pid: #{inspect(uart_pid)}")

    :ok =
      UART.open(
        uart_pid,
        "ttyAMA0",
        speed: 115_200,
        active: true,
        framing: {UART.Framing.Line, separator: "\r\n"},
        id: :pid
      )

    Logger.debug("***UART open")
    reset(uart_pid)
    {uart_pid, gpio, 0}
  end

  # Reset Modem
  defp reset(pid) do
    UART.write(pid, "ATZ")
    :timer.sleep(500)
  end

  defp toggle_power(gpio) do
    :ok = GPIO.write(gpio, 0)
    :timer.sleep(200)
    :ok = GPIO.write(gpio, 1)
    :timer.sleep(200)
    :ok = GPIO.write(gpio, 0)
  end
end
