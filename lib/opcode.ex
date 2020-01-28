defmodule Opcode do
  @default_mode 0
  @default_value 0

  @position_mode 0
  @immediate_mode 1

  @lengths %{
    1 => 4,
    2 => 4,
    3 => 2,
    4 => 2,
    5 => 3,
    6 => 3,
    7 => 4,
    8 => 4,
    99 => 1
  }

  defstruct number: 99, modes: [], pos: 0, length: 1

  @doc """
  iex> Opcode.from(2).number
  2

  iex> Opcode.from(1002).number
  2

  iex> Opcode.from(1002).modes
  [0,1,0]

  iex> Opcode.from(1102).modes
  [1,1,0]

  iex> Opcode.from(1202).modes
  [2,1,0]

  iex> Opcode.from(3).length
  2

  iex> Opcode.from(1202).length
  4
  """
  def from(num, pos \\ 0) when is_integer(num) do
    chars = num |> Integer.to_charlist()

    number =
      case chars do
        [_, _ | _] ->
          chars
          |> Enum.slice(-2, 2)
          |> List.to_string()
          |> String.to_integer()

        [_ | _] ->
          num
      end

    length = @lengths |> Map.get(number, 1)

    extract_modes =
      chars
      |> Enum.slice(0..-3)
      |> Enum.map(&List.to_integer([&1]))

    fill_in_empty_modes = for _ <- length(extract_modes)..(length - 2), do: @default_mode

    modes =
      (fill_in_empty_modes ++ extract_modes)
      |> Enum.reverse()

    %Opcode{number: number, modes: modes, pos: pos, length: length}
  end

  def indexes(opcode, program) do
    program.code
    |> Enum.slice(opcode.pos + 1, opcode.length - 1)
  end

  def values(opcode, program) do
    indexes(opcode, program)
    |> Enum.with_index()
    |> Enum.map(fn {n, i} ->
      case Enum.at(opcode.modes, i) do
        @position_mode ->
          Enum.at(program.code, n, @default_value)

        @immediate_mode ->
          n
      end
    end)
  end

  def new_pos(%{pos: pos, length: length}) do
    pos + length
  end
end
