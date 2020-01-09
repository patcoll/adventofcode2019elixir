defmodule Grid do
  @type point :: {integer, integer}
  @type path :: {char, integer}

  @doc """

  ## Examples
  iex> Grid.move("R2")
  [{0, 0}, {1, 0}, {2, 0}]

  iex> Grid.move("R2") |> Grid.move("L2")
  [{0, 0}, {1, 0}, {2, 0}, {1, 0}, {0, 0}]

  iex> Grid.move("R2") |> Grid.move("U2")
  [{0, 0}, {1, 0}, {2, 0}, {2, 1}, {2, 2}]

  iex> Grid.move({'U', 2})
  [{0, 0}, {0, 1}, {0, 2}]

  iex> Grid.move({1, 2}, {'L', 5})
  [{1, 2}, {0, 2}, {-1, 2}, {-2, 2}, {-3, 2}, {-4, 2}]

  """

  @spec move(String.t()) :: [point]
  def move(str) when is_binary(str), do: move(path(str))

  @spec move(path) :: [point]
  def move(path) when is_tuple(path), do: move({0, 0}, path)

  @spec move(point, path) :: [point]
  def move(point, path) when is_tuple(point) and is_tuple(path), do: move([point], path)

  @spec move([point], String.t()) :: [point]
  def move(points, str) when is_list(points) and is_binary(str) do
    move(points, path(str))
  end

  @spec move([point], path) :: [point]
  def move(points, path) when is_list(points) and is_tuple(path) do
    {dir, count} = path

    {last_x, last_y} = points |> List.last()

    add =
      1..count
      |> Enum.map(fn n ->
        case dir do
          'U' ->
            {last_x, last_y + n}

          'D' ->
            {last_x, last_y - n}

          'L' ->
            {last_x - n, last_y}

          'R' ->
            {last_x + n, last_y}
        end
      end)

    points |> Enum.concat(add)
  end

  @doc """

  ## Examples
  iex> Grid.path("U2")
  {'U', 2}

  """
  @spec path(String.t()) :: path
  def path(str) when is_binary(str) do
    str
    |> String.split("")
    |> Enum.reject(&(String.length(&1) == 0))
    |> Enum.map(fn val ->
      case Integer.parse(val) do
        {n, _} -> n
        _ -> val |> String.to_charlist()
      end
    end)
    |> List.to_tuple()
  end
end
