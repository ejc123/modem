defmodule ExModem.GPS do
  use GenServer

  @moduledoc """
    Set up and use GPS
  """
  @on_duration 3000

  require Logger
  alias Circuits.UART

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def start(pid) do
    Logger.debug("***start_GPS: #{inspect(pid)}")
    GenServer.cast(pid, :start)
  end

  def stop(pid) do
    GenServer.cast(pid, :stop)
  end

  # Server

  @impl GenServer
  @spec init(any) :: {:ok, {-1, false}}
  def init(_state) do
    {:ok, {-1, false}}
  end

  @impl GenServer
  def handle_cast(:stop, {uart_pid, _} = _state) do
    stop_GPS(uart_pid)
    {:noreply, {uart_pid, true}}
  end

  @impl GenServer
  def handle_cast(:start, {uart_pid, _} = _state) do
    start_GPS(uart_pid)
    schedule_work()
    {:noreply, {uart_pid, false}}
  end

  @impl GenServer
  def handle_info(:work, {uart_pid, stop?} = _state) do
    get_gps_info(uart_pid)

    unless stop? do
      schedule_work()
    end
  end

  @impl GenServer
  def handle_info({:nerves_uart, _pid, <<_::binary-10>> <> "1,1," <> <<rest::binary>>}, state) do
    Logger.info("***Rec: #{inspect(rest)}")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:nerves_uart, _pid, <<_::binary-10>> <> "1,0," <> <<rest::binary>>}, state) do
    Logger.info("***No Fix: #{inspect(rest)}")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:nerves_uart, _pid, <<_::binary-10>> <> "0," <> <<rest::binary>>}, state) do
    Logger.info("***N/C: #{inspect(rest)}")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(message, state) do
    Logger.debug("Other message #{inspect(message)}")
    {:noreply, state}
  end

  # Power on GPS and start listener
  defp start_GPS(uart_pid) do
    UART.write(uart_pid, "AT+CGNSPWR=1")
    :timer.sleep(500)
  end

  defp stop_GPS({uart_pid, _gps_pid}) do
    UART.write(uart_pid, "AT+CGNSPWR=0")
    :timer.sleep(500)
  end

  # Check state of GPS
  #  defp check_GPS_state(uart_pid) do
  #    UART.write(uart_pid, "AT+CGNSPWR?")
  #  end

  # Set echo off
  #  defp echo_off(uart_pid) do
  #    UART.write(uart_pid, "ATE0")
  #  end

  # Set echo on
  #  defp echo_on(uart_pid) do
  #    UART.write(uart_pid, "ATE0")
  #  end

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

  defp schedule_work() do
    Process.send_after(self(), :work, @on_duration)
  end
end
