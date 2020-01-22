defmodule Grid do
  @directions 'UDLR'

  @type point :: {integer, integer}
  @type path :: {charlist, integer}
  @type route :: [point]

  @doc """

  ## Examples

  iex> Grid.move("R2")
  [{0, 0}, {1, 0}, {2, 0}]

  iex> Grid.move("R2") |> Grid.move("U2")
  [{0, 0}, {1, 0}, {2, 0}, {2, 1}, {2, 2}]

  iex> Grid.move([], {'L', 5})
  [{0, 0}, {-1, 0}, {-2, 0}, {-3, 0}, {-4, 0}, {-5, 0}]

  iex> Grid.move([{1, 2}], {'L', 5})
  [{1, 2}, {0, 2}, {-1, 2}, {-2, 2}, {-3, 2}, {-4, 2}]
  """

  @spec move(route, path | String.t() | nonempty_charlist) :: route
  def move(points \\ [], str)

  def move(points, str) when is_list(points) and is_binary(str) do
    move(points, path(str))
  end

  # @spec move(route, path) :: route
  def move([] = _points, {_, _} = path) do
    move([{0, 0}], path)
  end

  # @spec move(route, path) :: route
  def move([_ | _] = points, {dir, count}) do
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

    points ++ add
  end

  @doc """
  Take a charlist or string and return a path tuple.

  ## Examples

  iex> Grid.path('L10')
  {'L', 10}

  iex> Grid.path("U2")
  {'U', 2}

  """
  @spec path(String.t() | nonempty_charlist) :: path
  def path([dir | rest]) when dir in @directions do
    {[dir], List.to_integer(rest)}
  end

  # @spec path(String.t()) :: path
  def path(str) when is_binary(str) do
    path(String.to_charlist(str))
  end

  @doc """
  Take a string with comma-separated paths and return a full route list with all points.

  ## Examples
  iex> Grid.route("R2,U2")
  [{0, 0}, {1, 0}, {2, 0}, {2, 1}, {2, 2}]
  iex> Grid.route("L2, U10")
  [{0, 0}, {-1, 0}, {-2, 0}, {-2, 1}, {-2, 2}, {-2, 3}, {-2, 4}, {-2, 5}, {-2, 6}, {-2, 7}, {-2, 8}, {-2, 9}, {-2, 10}]

  """
  @spec route(String.t()) :: route
  def route(str) when is_binary(str) do
    str
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reduce([], &Grid.move(&2, &1))
  end

  def intersection([_ | _] = routes) do
    routes
    |> Enum.map(&MapSet.new/1)
    |> Enum.reduce(&MapSet.intersection(&1, &2))
    |> MapSet.difference(MapSet.new([{0, 0}]))
    |> Enum.to_list()
  end

  @doc """
  Take a string with comma-separated paths and return a full route list with all points.

  ## Examples
  iex> Grid.closest_distance_to_origin(
  ...>   [Grid.route("L2, U10"), Grid.route("U2, L3, U2, R3, U2, L3")]
  ...> )
  4
  iex> Grid.closest_distance_to_origin(
  ...>   [Grid.route("R75,D30,R83,U83,L12,D49,R71,U7,L72"), Grid.route("U62,R66,U55,R34,D71,R55,D58,R83")]
  ...> )
  159
  iex> Grid.closest_distance_to_origin(
  ...>   [Grid.route("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51"), Grid.route("U98,R91,D20,R16,D67,R40,U7,R15,U6,R7")]
  ...> )
  135

  """
  @spec route([route]) :: integer
  def closest_distance_to_origin([_ | _] = routes) do
    routes
    |> intersection
    |> Enum.map(fn {x, y} -> abs(x) + abs(y) end)
    |> Enum.min()
  end

  @doc """
  iex> Grid.intersection_shortest_path([
  ...>   Grid.route("R75,D30,R83,U83,L12,D49,R71,U7,L72"),
  ...>   Grid.route("U62,R66,U55,R34,D71,R55,D58,R83"),
  ...> ])
  610
  iex> Grid.intersection_shortest_path([
  ...>   Grid.route("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51"),
  ...>   Grid.route("U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"),
  ...> ])
  410
  """
  def intersection_shortest_path([_ | _] = routes) do
    intersection = routes |> intersection

    intersection
    |> Enum.map(fn intersected_coord ->
      routes
      |> Enum.map(fn route ->
        route |> Enum.find_index(&(&1 == intersected_coord))
      end)
      |> Enum.sum()
    end)
    |> Enum.min()
  end
end
