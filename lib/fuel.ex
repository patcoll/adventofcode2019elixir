defmodule Fuel do
  @doc """

  ## Examples
  iex> Fuel.fuel_needed_for_mass(1)
  0
  iex> Fuel.fuel_needed_for_mass(12)
  2
  iex> Fuel.fuel_needed_for_mass(14)
  2
  iex> Fuel.fuel_needed_for_mass(1969)
  654
  iex> Fuel.fuel_needed_for_mass(100_756)
  33_583

  """
  # NOTE: Can this do any type checking on compile?
  @spec fuel_needed_for_mass(integer) :: integer
  def fuel_needed_for_mass(mass) when is_integer(mass) do
    case mass |> div(3) |> Kernel.-(2) do
      fuel when fuel > 0 -> fuel
      _ -> 0
    end
  end

  @doc """

  ## Examples
  iex> Fuel.total_fuel_needed_for_mass(1)
  0
  iex> Fuel.total_fuel_needed_for_mass(12)
  2
  iex> Fuel.total_fuel_needed_for_mass(14)
  2
  iex> Fuel.total_fuel_needed_for_mass(1969)
  966
  iex> Fuel.total_fuel_needed_for_mass(100_756)
  50_346

  """
  @spec total_fuel_needed_for_mass(integer) :: integer
  def total_fuel_needed_for_mass(mass) when is_integer(mass) do
    case fuel_needed_for_mass(mass) do
      fuel when fuel > 0 ->
        fuel + total_fuel_needed_for_mass(fuel)
      _ -> 0
    end
  end
end
