defmodule Grid do
  @type point :: {integer, integer}
  @type path :: {char, integer}
  @type route :: [point]

  @doc """

  ## Examples

  iex> Grid.move("R2")
  [{0, 0}, {1, 0}, {2, 0}]

  iex> Grid.move({'U', 2})
  [{0, 0}, {0, 1}, {0, 2}]

  iex> Grid.move({1, 2}, {'L', 5})
  [{1, 2}, {0, 2}, {-1, 2}, {-2, 2}, {-3, 2}, {-4, 2}]

  iex> Grid.move([{1, 2}], "L5")
  [{1, 2}, {0, 2}, {-1, 2}, {-2, 2}, {-3, 2}, {-4, 2}]

  # Used for simpler `reduce` compatibility.
  iex> Grid.move("L5", [{0, 0}, {0, 1}, {0, 2}])
  [{0, 0}, {0, 1}, {0, 2}, {-1, 2}, {-2, 2}, {-3, 2}, {-4, 2}, {-5, 2}]

  iex> Grid.move([], {'L', 5})
  [{0, 0}, {-1, 0}, {-2, 0}, {-3, 0}, {-4, 0}, {-5, 0}]

  # Used for simpler `reduce` compatibility.
  iex> Grid.move({'L', 5}, [{1, 2}])
  [{1, 2}, {0, 2}, {-1, 2}, {-2, 2}, {-3, 2}, {-4, 2}]

  iex> Grid.move([{1, 2}], {'L', 5})
  [{1, 2}, {0, 2}, {-1, 2}, {-2, 2}, {-3, 2}, {-4, 2}]
  """

  @spec move(String.t()) :: route
  def move(str) when is_binary(str), do: move(path(str))

  @spec move(path) :: route
  def move(path) when is_tuple(path), do: move({0, 0}, path)

  @spec move(point, path) :: route
  def move(point, path) when is_tuple(point) and is_tuple(path), do: move([point], path)

  @spec move(route, String.t()) :: route
  def move(points, str) when is_list(points) and is_binary(str) do
    move(points, path(str))
  end

  @spec move(String.t(), route) :: route
  def move(str, points) when is_list(points) and is_binary(str) do
    move(points, path(str))
  end

  @spec move(route, path) :: route
  def move(points, path) when is_list(points) and length(points) == 0 and is_tuple(path) do
    move(path)
  end

  @spec move(path, route) :: route
  def move(path, points) when is_list(points) and length(points) > 0 and is_tuple(path) do
    move(points, path)
  end

  @spec move(route, path) :: route
  def move(points, path) when is_list(points) and length(points) > 0 and is_tuple(path) do
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
  Take a charlist or string and return a path tuple.

  ## Examples

  iex> Grid.path('L10')
  {'L', 10}

  iex> Grid.path("U2")
  {'U', 2}

  """
  @spec path(list) :: path
  def path(list) when is_list(list) and length(list) > 1 do
    [dir | rest] = list
    {[dir], List.to_integer(rest)}
  end

  @spec path(String.t()) :: path
  def path(str) when is_binary(str) do
    path(String.to_charlist(str))
  end

  @doc """
  Take a string with comma-separated paths and return a full route list with all points.

  ## Examples
  iex> Grid.route("R2,U2")
  [{0, 0}, {1, 0}, {2, 0}, {2, 1}, {2, 2}]

  """
  @spec route(String.t()) :: route
  def route(str) when is_binary(str) do
    str
    |> String.split(",", trim: true)
    |> Enum.reduce([], &Grid.move/2)
  end
end
