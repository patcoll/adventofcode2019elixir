defmodule Orbits do
  @type universe :: MapSet.t()
  @type orbit_map :: %{required(%Mass{}) => list(%Mass{})}
  @type orbit_set :: MapSet.t(%Orbit{})
  # @type path_set :: MapSet.t(list(Mass.name))
  @type path_list :: list(list(Mass.name()))
  # @type visited_orbits :: MapSet.t(Mass.name)

  @doc """
    iex> Orbits.from("COM)B  B)C")
    #MapSet<[%Mass{name: "B"}, %Mass{name: "C"}, %Mass{name: "COM"}, %Orbit{orbited: %Mass{name: "B"}, orbiting: %Mass{name: "C"}}, %Orbit{orbited: %Mass{name: "COM"}, orbiting: %Mass{name: "B"}}]>
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

  @doc """
  Takes a universe that models a directed graph and returns a model of an undirected graph.

  iex> Orbits.from("COM)B  B)C") |> Orbits.undirected
  #MapSet<[%Mass{name: "B"}, %Mass{name: "C"}, %Mass{name: "COM"}, %Orbit{orbited: %Mass{name: "B"}, orbiting: %Mass{name: "C"}}, %Orbit{orbited: %Mass{name: "B"}, orbiting: %Mass{name: "COM"}}, %Orbit{orbited: %Mass{name: "C"}, orbiting: %Mass{name: "B"}}, %Orbit{orbited: %Mass{name: "COM"}, orbiting: %Mass{name: "B"}}]>
  """
  @spec undirected(universe) :: universe
  def undirected(universe) do
    opposite_edges =
      universe
      |> Enum.filter(fn
        %Orbit{} -> true
        _ -> false
      end)
      |> Enum.map(&%Orbit{orbited: &1.orbiting, orbiting: &1.orbited})
      |> MapSet.new()

    universe
    |> MapSet.union(opposite_edges)
  end

  @doc """
  iex> Orbits.from("COM)B  B)C") |> Orbits.all |> Enum.count
  2
  """
  @spec all(universe) :: [%Orbit{}]
  def all(universe) do
    universe
    |> Enum.filter(fn
      %Orbit{} -> true
      _ -> false
    end)
  end

  @spec map(universe) :: orbit_map
  defp map(universe) do
    {orbits, masses} =
      universe
      |> Enum.split_with(fn
        %Orbit{} -> true
        _ -> false
      end)

    defaults =
      masses
      |> Enum.map(&%{&1 => MapSet.new()})
      |> Enum.reduce(&Map.merge/2)

    orbit_map =
      orbits
      |> Enum.reduce(defaults, fn orbit, map ->
        %{
          map
          | orbit.orbited =>
              MapSet.union(Map.get(map, orbit.orbited), MapSet.new([orbit.orbiting]))
        }
      end)

    orbit_map
  end

  @doc """
  iex> Orbits.from("COM)A  A)B  B)C") |> Orbits.indirect |> Enum.count
  6
  iex> Orbits.from("COM)B  B)C  C)D  D)E  E)F  B)G  G)H  D)I  E)J  J)K  K)L") |> Orbits.indirect |> Enum.count
  42
  """
  @spec indirect(universe, String.t()) :: orbit_set
  def indirect(universe, start \\ "COM") do
    universe
    |> map
    |> indirect_search(start)
  end

  @spec indirect_search(orbit_map, String.t()) :: orbit_set
  defp indirect_search(%{} = orbit_map, start) when is_binary(start) do
    root_mass = %Mass{name: start}

    orbit_map
    |> Map.get(root_mass)
    |> Enum.reduce(MapSet.new(), fn mass_orbiting_root, all ->
      this_mass_orbit =
        MapSet.new([
          %Orbit{orbited: root_mass, orbiting: mass_orbiting_root}
        ])

      processed_children =
        case MapSet.size(orbit_map[mass_orbiting_root]) do
          0 ->
            MapSet.new()

          _ ->
            children = indirect_search(orbit_map, mass_orbiting_root.name)

            # take note of indirect orbits of children
            indirect =
              children
              |> Enum.map(fn child ->
                %Orbit{orbited: root_mass, orbiting: child.orbiting}
              end)
              |> MapSet.new()

            # merge
            children
            |> MapSet.union(indirect)
        end

      all
      |> MapSet.union(this_mass_orbit)
      |> MapSet.union(processed_children)
    end)
  end

  @doc """
  iex> Orbits.from("COM)B B)C C)D D)E E)F B)G G)H D)I E)J J)K K)L K)YOU I)SAN")
  ...> |> Orbits.get_minimal_orbital_transfer_count("YOU", "SAN")
  4
  """
  def get_minimal_orbital_transfer_count(universe, start, finish) do
    find_shortest_path(universe, start, finish)
    |> Enum.count()
    |> Kernel.-(3)
  end

  @doc """
  iex> Orbits.from("A)B B)D C)D B)E D)E") |> Orbits.find_shortest_path("E", "C")
  ["E", "D", "C"]
  iex> Orbits.from("COM)B B)C C)D D)E E)F B)G G)H D)I E)J J)K K)L K)YOU I)SAN")
  ...> |> Orbits.find_shortest_path("YOU", "SAN")
  ["YOU", "K", "J", "E", "D", "I", "SAN"]
  """
  def find_shortest_path(universe, start, finish) do
    use_libgraph = Application.fetch_env!(:adventofcode2019elixir, :shortest_path_use_libgraph)

    if use_libgraph do
      edges = universe |> undirected |> all

      graph =
        Graph.new()
        |> Graph.add_edges(
          Enum.map(edges, fn
            %Orbit{orbited: start_edge, orbiting: end_edge} ->
              {start_edge.name, end_edge.name}
          end)
        )

      graph |> Graph.dijkstra(start, finish)
    else
      universe
      |> undirected
      |> map
      |> find_paths(start, finish)
      |> Enum.min_by(&length/1)
    end
  end

  @spec find_paths(map, list(Mass.name()), Mass.name(), path_list) :: path_list
  defp find_paths(%{} = orbit_map, start, finish, all \\ []) do
    start = List.wrap(start)
    start_item = List.last(start)

    start_mass = %Mass{name: start_item}

    is_candidate = fn path -> List.last(path) == finish end

    neighbors =
      orbit_map
      |> Map.get(start_mass)
      |> MapSet.difference(MapSet.new(Enum.map(start, &%Mass{name: &1})))

    neighbors
    |> Enum.map(fn mass_orbiting_start ->
      Task.async(fn ->
        orbit_path = start ++ [mass_orbiting_start.name]

        all_plus_current = all ++ [orbit_path]

        if mass_orbiting_start.name != finish do
          from_children =
            find_paths(orbit_map, orbit_path, finish, all_plus_current)
            |> Enum.filter(is_candidate)

          all_plus_current ++ from_children
        else
          [orbit_path]
        end
      end)
    end)
    |> Enum.map(&Task.await(&1, 15_000))
    |> Enum.reduce(all, &Kernel.++/2)
    |> Enum.filter(is_candidate)
  end
end
