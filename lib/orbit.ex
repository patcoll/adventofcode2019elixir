defmodule Orbit do
  @enforce_keys [:orbited, :orbiting]
  defstruct [:orbited, :orbiting]

  @doc """
    iex> Orbit.from("A)B")
    [%Mass{name: "A"}, %Mass{name: "B"}, %Orbit{orbited: %Mass{name: "A"}, orbiting: %Mass{name: "B"}}]
  """
  def from(str) when is_binary(str) do
    str
    |> String.trim()
    |> String.split(")")
    |> Enum.map(&%Mass{name: &1})
    |> Enum.reduce(fn orbiting, orbited ->
      [orbited, orbiting, %Orbit{orbited: orbited, orbiting: orbiting}]
    end)
  end
end
