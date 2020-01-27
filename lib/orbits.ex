defmodule Orbits do
  @type universe :: MapSet.t()
  @type mass :: String.t()
  @type orbited :: mass
  @type orbiting :: mass
  @type orbit :: {orbited, orbiting}
  @type orbit_map :: %{required(orbiting) => orbited}

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
    |> Enum.map(&MapSet.new/1)
    |> Enum.reduce(&MapSet.union/2)
  end

  @spec split(universe) :: {[mass], [orbit]}
  def split(universe) do
    universe
    |> Enum.split_with(fn
      "" <> _ -> true
      _ -> false
    end)
  end

  @doc """
  iex> Orbits.from("COM)A  A)B  B)C") |> Orbits.map
  %{"A" => "COM", "B" => "A", "C" => "B"}
  """
  @spec map(universe) :: orbit_map
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
  @spec indirect_count(universe) :: integer
  def indirect_count(universe) do
    {masses, _} = universe |> split

    masses
    |> Enum.map(fn mass ->
      Task.async(fn ->
        find_path_to_root(universe, mass)
        |> Enum.count()
      end)
    end)
    |> Enum.map(&Task.await(&1))
    |> Enum.sum()
  end

  @doc """
  iex> Orbits.from("COM)B B)C C)D D)E E)F B)G G)H D)I E)J J)K K)L K)YOU I)SAN")
  ...> |> Orbits.get_minimal_orbital_transfer_count("YOU", "SAN")
  4
  """
  @spec get_minimal_orbital_transfer_count(universe, mass, mass) :: integer
  def get_minimal_orbital_transfer_count(universe, start, finish) do
    routes =
      [start, finish]
      |> Enum.map(&find_path_to_root(universe, &1))

    use_find_divergence = Application.fetch_env!(:adventofcode2019elixir, :use_find_divergence)

    if use_find_divergence do
      routes
      |> Enum.map(&Enum.reverse/1)
      |> Enum.reduce(fn finish_path, start_path ->
        {_, start_path_to_parent, finish_path_to_parent} =
          find_divergence(start_path, finish_path)

        [start_path_to_parent, finish_path_to_parent]
        |> Enum.map(&Enum.count/1)
        |> Enum.sum()
      end)
    else
      # TODO: this looks really familiar; intersection_shortest_path could solve this too after a refactor.
      intersection =
        routes
        |> Enum.map(&MapSet.new/1)
        |> Enum.reduce(&MapSet.intersection/2)

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

  def find_divergence(path1, path2, parent \\ nil)
  def find_divergence([h | t1], [h | t2], _parent), do: find_divergence(t1, t2, h)
  def find_divergence(path1, path2, parent), do: {parent, path1, path2}
end
