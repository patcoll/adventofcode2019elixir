defmodule LibTest do
  use ExUnit.Case

  test :day_01 do
    input =
      Path.expand("data/d01.txt", __DIR__)
      |> File.read!()
      |> String.trim()
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)

    total =
      input
      |> Enum.map(&Fuel.fuel_needed_for_mass/1)
      |> Enum.sum()

    assert total == 3_318_195
  end

  test :day_01_part_2 do
    input =
      Path.expand("data/d01.txt", __DIR__)
      |> File.read!()
      |> String.trim()
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)

    total =
      input
      |> Enum.map(&Fuel.total_fuel_needed_for_mass/1)
      |> Enum.sum()

    assert total == 4_974_428
  end

  test :day_02 do
    input =
      Path.expand("data/d02.txt", __DIR__)
      |> File.read!()
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> List.replace_at(1, 12)
      |> List.replace_at(2, 2)

    output = Program.run(input)

    assert output |> Enum.at(0) == 9_706_670
  end

  test :day_02_part_2 do
    input =
      Path.expand("data/d02.txt", __DIR__)
      |> File.read!()
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    {:ok, {i, j}} = Program.run_to_get_output(input, 19_690_720)

    assert i == 25
    assert j == 52
    assert i * 100 + j == 2552
  end
end
