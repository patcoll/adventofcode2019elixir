defmodule Orbits do
  @type universe :: MapSet.t()

  @doc """
    iex> Orbits.from("COM)B  B)C")
    #MapSet<[%Mass{name: "B"}, %Mass{name: "C"}, %Mass{name: "COM"}, %Orbit{orbited: %Mass{name: "B"}, orbiting: %Mass{name: "C"}}, %Orbit{orbited: %Mass{name: "COM"}, orbiting: %Mass{name: "B"}}]>
  """
  @spec from(String.t) :: universe
  def from(str) when is_binary(str) do
    str
    |> String.trim
    |> String.split
    |> Enum.map(&Orbit.from/1)
    |> Enum.reduce(MapSet.new, fn orbit, set ->
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
    # orbits = direct(universe)

    {orbits, masses} =
      universe
      |> Enum.split_with(fn
        %Orbit{} -> true
        _ -> false
      end)

    defaults =
      masses
      |> Enum.map(&(%{&1 => []}))
      |> Enum.reduce(&Map.merge/2)

    # IO.inspect("graph")
    # graph =
    #   Graph.new
    #   |> Graph.add_edges(orbits |> Enum.map(&({&1.orbited.name, &1.orbiting.name})))
    #   # |> IO.inspect
    #
    #
    # vertices = graph |> Graph.vertices
    #
    # graph
    # |> Graph.Reducers.Bfs.reduce(0, fn vertex, acc ->
    #   # "vertex" |> IO.inspect
    #   # vertex |> IO.inspect
    #   paths =
    #     vertices
    #     |> Stream.map(fn v ->
    #       # v |> IO.inspect
    #       Task.async(fn ->
    #         if vertex != v && Graph.dijkstra(graph, vertex, v) do
    #           1
    #         else
    #           0
    #         end
    #       end)
    #     end)
    #     |> Stream.map(&Task.await(&1, :infinity))
    #     |> Enum.sum
    #   {:next, acc + paths}
    # end)
    # |> IO.inspect
    # |> Enum.sum
    # |> IO.inspect

    # stream = Task.async_stream(vertices, fn vertex ->
    # vertices
    # |> Stream.map(fn vertex ->
    #   Task.async(fn ->
    #     vertices
    #     |> Stream.map(fn v ->
    #       Task.async(fn ->
    #         if vertex != v && Graph.dijkstra(graph, vertex, v) do
    #           1
    #         else
    #           0
    #         end
    #       end)
    #     end)
    #     |> Enum.map(&Task.await(&1, :infinity))
    #     # |> Enum.reject(&is_nil/1)
    #   end)
    # end)
    # |> Stream.flat_map(&(&1))
    # |> IO.inspect
    # |> Stream.flat_map
    # end, ordered: false)
    # |> Stream.flat_map(fn {:ok, tasks} ->
    #   tasks
    # end)
    # |> Stream.flat_map(&Task.await(&1, :infinity))
    # |> Enum.sum
    # |> IO.inspect
    # |> Enum.reject(&is_nil/1)
    # |> IO.inspect
    # |> Stream.flat_map(&(&1))
    # |> IO.inspect
    # |> Enum.map(&Task.await/1)
    # |> IO.inspect
    # |> Enum.reject(&is_nil/1)
    # |> IO.inspect

    # vertices
    # |> Enum.flat_map(fn vertex ->
    #   vertices
    #   |> Enum.map(fn v ->
    #     Task.async(fn ->
    #       if vertex != v do
    #         Graph.dijkstra(graph, vertex, v)
    #       end
    #     end)
    #   end)
    #   # |> Enum.reject(&is_nil/1)
    #   # |> IO.inspect
    # end)
    # |> IO.inspect
    # |> Enum.map(&Task.await/1)
    # |> IO.inspect
    # |> Enum.reject(&is_nil/1)
    # |> IO.inspect
    # |> Enum.map(fn [_,_ | _] = path ->
    #   %Orbit{orbited: Enum.at(path, 0), orbiting: Enum.at(path, -1)}
    # end)
    # |> IO.inspect
    # |> Enum.count
    # |> IO.inspect

    # |> Graph.dijkstra("COM", "K")
    # |> IO.inspect

    orbit_map =
      orbits
      |> Enum.reduce(defaults, fn orbit, map ->
        %{map | orbit.orbited => Map.get(map, orbit.orbited) ++ [orbit.orbiting]}
      end)

    # Start at root.
    indirect_search(orbit_map, root_name)
    # |> Enum.count
  end

  defp indirect_search(%{} = orbit_map, root_name) when is_binary(root_name) do
    # Graph.new |> IO.inspect

    root_mass = %Mass{name: root_name}

    orbit_map
    |> Map.get(root_mass)
    # |> IO.inspect
    |> Enum.reduce(MapSet.new, fn mass_orbiting_root, all ->
      # IO.inspect("all")
      # all |> IO.inspect

      # IO.inspect("mass_orbiting_root")
      # mass_orbiting_root |> IO.inspect

      this_mass_orbit = MapSet.new([
        %Orbit{orbited: root_mass, orbiting: mass_orbiting_root}
      ])

      processed_children =
        case length(orbit_map[mass_orbiting_root]) do
          0 -> MapSet.new
          _ ->
            # handle children
            # IO.puts("diving deeper: #{root_name} -> #{mass_orbiting_root.name}")
            # IO.inspect("children")
            children =
              indirect_search(orbit_map, mass_orbiting_root.name)
              # |> IO.inspect

            # take note of indirect orbits of children
            # IO.inspect("indirect")
            indirect =
              children
              # |> IO.inspect
              |> Enum.map(fn child ->
                # IO.inspect("child")
                # IO.inspect(child)
                %Orbit{orbited: root_mass, orbiting: child.orbiting}
              end)
              |> MapSet.new
              # |> IO.inspect

            # merge
            children
            |> MapSet.union(indirect)
        end

      # IO.inspect("return")
      # IO.puts("return from: #{root_name} -> #{mass_orbiting_root.name}")
      all
      |> MapSet.union(this_mass_orbit)
      |> MapSet.union(processed_children)
      # |> IO.inspect
    end)
  end
end
