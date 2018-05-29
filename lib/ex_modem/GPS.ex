defmodule ExModem.GPS do
  use GenServer

  @moduledoc """
    Set up and use GPS
  """

  # Durations are in milliseconds
  @on_duration 3000

  alias Nerves.UART
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(state) do
    tty = "ttyAMA0"
    options = [speed: 115_200, active: true, framing: {Framing.Line, separator: "\r\n"}, id: :pid]
    {uart_pid, gpio_pid, gps_pid} = start(tty, options)
    {:ok, {uart_pid, gpio_pid, gps_pid, options}}
  end

  # GenServer callbacks
  @impl true
  def handle_call({:start, tty, options}, _from, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(:start_gps, _from, {uart_pid, gpio_pid, gps_pid} = state) when gps_pid == 0 do
    Logger.debug("***start_gps: #{inspect(state)}")
    {:noreply, {uart_pid, gpio_pid, start_GPS(uart_pid)}}
  end

  @impl true
  def handle_info(:start_gps, _from, {uart_pid, gpio_pid, gps_pid} = state) do
    {:noreply, {uart_pid, gpio_pid, gps_pid}}
  end

  @impl true
  def handle_info(:stop_gps, _from, {uart_pid, gpio_pid, gps_pid} = state) do
    stop_GPS({uart_pid, gps_pid})
    {:noreply, {uart_pid, gpio_pid, 0}}
  end

  # Handle messages from gps UART
  @impl true
  def handle_info({:nerves_uart, _pid, <<_::binary-10>> <> "1,1," <> <<rest::binary>>}, state) do
    Logger.info("***Rec: #{inspect(rest)}")
    {:noreply, state}
  end

  @impl true
  def handle_info({:nerves_uart, _pid, <<_::binary-10>> <> "1,0," <> <<rest::binary>>}, state) do
    Logger.info("***No Fix: #{inspect(rest)}")
    {:noreply, state}
  end

  @impl true
  def handle_info({:nerves_uart, _pid, <<_::binary-10>> <> "0," <> <<rest::binary>>}, state) do
    Logger.info("***N/C: #{inspect(rest)}")
    {:noreply, state}
  end

  @impl true
  def handle_info(message, state) do
    Logger.debug("Other message #{inspect(message)}")
    {:noreply, state}
  end

  # private functions
  defp start(tty, options) do
    {:ok, gpio_pid} = ElixirALE.GPIO.start_link(4, :output)
    toggle_power(gpio_pid)
    :timer.sleep(1500)
    toggle_power(gpio_pid)
    # Pause to let modem reset before we query it
    :timer.sleep(2000)

    Logger.info("***start, gpio_pid: #{inspect(gpio_pid)}")
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
    {uart_pid, gpio_pid, 0}
  end

  # Reset Modem
  defp reset(pid) do
    UART.write(pid, "ATZ")
    :timer.sleep(500)
  end

  # Power on GPS and start listener
  defp start_GPS(uart_pid) do
    UART.write(uart_pid, "AT+CGNSPWR=1")
    :timer.sleep(500)
    Logger.info("***Spawning GPS loop...")
    gps_pid = spawn(fn -> gps_loop(uart_pid) end)
    Logger.info("***Listener started pid: #{gps_pid}...")
    gps_pid
  end

  defp stop_GPS({uart_pid, gps_pid}) do
    UART.write(uart_pid, "AT+CGNSPWR=0")
    :timer.sleep(500)
    Logger.info("***Stopping GPS loop...")
  end

  # Check state of GPS
  defp check_GPS_state(uart_pid) do
    UART.write(uart_pid, "AT+CGNSPWR?")
  end

  # Set echo off
  defp echo_off(uart_pid) do
    UART.write(uart_pid, "ATE0")
  end

  # Set echo on
  defp echo_on(uart_pid) do
    UART.write(uart_pid, "ATE0")
  end

  # Get GPS info
  # Here's what we get back
  # {:nerves_uart, "ttyAMA0", ""}
  # {:nerves_uart, "ttyAMA0",
  #  "+CGNSINF: 1,1,20180516190139.000,46.893477,-96.803717,270.035,0.00,349.1,2,,1.1,2.0,1.6,,10,10,,,44,,"}
  # {:nerves_uart, "ttyAMA0", ""}
  # {:nerves_uart, "ttyAMA0", "OK"}
  # :ok

  defp get_gps_info(uart_pid) do
    UART.write(uart_pid, "AT+CGNSINF")
  end

  defp gps_loop(uart_pid) do
    get_gps_info(uart_pid)
    :timer.sleep(@on_duration)
    gps_loop(uart_pid)
  end

  defp toggle_power(gpio_pid) do
    :ok = ElixirALE.GPIO.write(gpio_pid, 0)
    :timer.sleep(100)
    :ok = ElixirALE.GPIO.write(gpio_pid, 1)
    :timer.sleep(100)
    :ok = ElixirALE.GPIO.write(gpio_pid, 0)
  end
end
