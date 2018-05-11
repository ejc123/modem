defmodule ExModemTest do
  use ExUnit.Case
  doctest ExModem

  test "greets the world" do
    assert ExModem.hello() == :world
  end
end
