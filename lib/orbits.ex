defmodule Orbits do
  @type universe :: MapSet.t()

  @doc """
  iex> Orbits.from("COM)B  B)C")
  #MapSet<[{"B", "C"}, {"COM", "B"}, "B", "C", "COM"]>
  """
  @spec from(String.t()) :: universe
  def from(str) when is_binary(str) do
    str
    |> String.trim()
    |> String.split()
    |> Enum.map(&Orbit.from/1)
    |> Enum.reduce(MapSet.new(), fn orbit, set ->
      MapSet.union(set, MapSet.new(orbit))
    end)
  end

  def split(universe) do
    universe
    |> Enum.split_with(fn
      # _ -> false
      "" <> _ -> true
      # {_, _} -> false
      _ -> false
    end)
  end

  @doc """
  iex> Orbits.from("COM)A  A)B  B)C") |> Orbits.map
  %{"A" => "COM", "B" => "A", "C" => "B"}
  """
  @spec map(universe) :: map
  def map(universe) do
    {_, orbits} = universe |> split

    orbits
    |> Enum.reduce(%{}, fn {orbited, orbiting}, map ->
      map |> Map.put(orbiting, orbited)
    end)
  end

  @doc """
  iex> Orbits.from("COM)A  A)B  B)C") |> Orbits.find_path_to_root("COM")
  []

  iex> Orbits.from("COM)A  A)B  B)C") |> Orbits.find_path_to_root("A")
  ["COM"]

  iex> Orbits.from("COM)A  A)B  B)C") |> Orbits.find_path_to_root("B")
  ["A", "COM"]

  iex> Orbits.from("COM)A  A)B  B)C") |> Orbits.find_path_to_root("C")
  ["B", "A", "COM"]
  """
  def find_path_to_root(universe, orbiting_name) do
    do_find_path_to_root(map(universe), orbiting_name)
  end

  defp do_find_path_to_root(map, orbiting_name, path \\ []) do
    orbited_name = map |> Map.get(orbiting_name)

    if orbited_name do
      do_find_path_to_root(map, orbited_name, path ++ [orbited_name])
    else
      path
    end
  end

  @doc """
  iex> Orbits.from("COM)A  A)B  B)C") |> Orbits.indirect_count
  6
  iex> Orbits.from("COM)B  B)C  C)D  D)E  E)F  B)G  G)H  D)I  E)J  J)K  K)L")
  ...> |> Orbits.indirect_count
  42
  """
  @spec indirect_count(universe, String.t()) :: integer
  def indirect_count(universe, start \\ "COM") do
    {masses, _} = universe |> split

    masses
    |> Enum.map(&find_path_to_root(universe, &1))
    |> Enum.map(&Enum.count/1)
    |> Enum.sum()
  end

  @doc """
  iex> Orbits.from("COM)B B)C C)D D)E E)F B)G G)H D)I E)J J)K K)L K)YOU I)SAN")
  ...> |> Orbits.get_minimal_orbital_transfer_count("YOU", "SAN")
  4
  """
  def get_minimal_orbital_transfer_count(universe, start, finish) do
    # TODO: this looks really familiar; intersection_shortest_path could solve this too after a refactor.
    routes =
      [start, finish]
      |> Enum.map(&find_path_to_root(universe, &1))

    intersection =
      routes
      |> Enum.map(&MapSet.new/1)
      |> Enum.reduce(&MapSet.intersection(&1, &2))

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
