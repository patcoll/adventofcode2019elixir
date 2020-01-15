defmodule Orbits do
  @type universe :: MapSet.t()

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
  iex> Orbits.from("COM)B  B)C") |> Orbits.direct |> Enum.count
  2
  """
  @spec direct(universe) :: integer
  def direct(universe) do
    universe
    |> Enum.filter(fn
      %Orbit{} -> true
      _ -> false
    end)
  end

  @doc """
  iex> Orbits.from("COM)A  A)B  B)C") |> Orbits.indirect |> Enum.count
  6
  iex> Orbits.from("COM)B  B)C  C)D  D)E  E)F  B)G  G)H  D)I  E)J  J)K  K)L") |> Orbits.indirect |> Enum.count
  42
  """
  @spec indirect(universe) :: map
  def indirect(universe, root_name \\ "COM") do
    {orbits, masses} =
      universe
      |> Enum.split_with(fn
        %Orbit{} -> true
        _ -> false
      end)

    defaults =
      masses
      |> Enum.map(&%{&1 => []})
      |> Enum.reduce(&Map.merge/2)

    orbit_map =
      orbits
      |> Enum.reduce(defaults, fn orbit, map ->
        %{map | orbit.orbited => Map.get(map, orbit.orbited) ++ [orbit.orbiting]}
      end)

    indirect_search(orbit_map, root_name)
  end

  defp indirect_search(%{} = orbit_map, root_name) when is_binary(root_name) do
    root_mass = %Mass{name: root_name}

    orbit_map
    |> Map.get(root_mass)
    |> Enum.reduce(MapSet.new(), fn mass_orbiting_root, all ->
      this_mass_orbit =
        MapSet.new([
          %Orbit{orbited: root_mass, orbiting: mass_orbiting_root}
        ])

      processed_children =
        case length(orbit_map[mass_orbiting_root]) do
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
end
