defmodule LibTest do
  use ExUnit.Case

  test :day_01 do
    input = Path.expand("data/d01.txt", __DIR__)
      |> File.read!
      |> String.trim()
      |> String.split()
      |> Enum.map(&String.to_integer/1)

    total = input
      |> Enum.map(&Fuel.fuel_needed_for_mass/1)
      |> Enum.sum()

    assert total == 3_318_195
  end

  test :day_01_part_2 do
    input = Path.expand("data/d01.txt", __DIR__)
      |> File.read!
      |> String.trim()
      |> String.split()
      |> Enum.map(&String.to_integer/1)

    total = input
      |> Enum.map(&Fuel.total_fuel_needed_for_mass/1)
      |> Enum.sum()

    assert total == 4_974_428
  end
end
