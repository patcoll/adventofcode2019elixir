defmodule Orbit do
  @doc """
  iex> Orbit.from("A)B")
  ["A", "B", {"A", "B"}]
  """
  def from(str) when is_binary(str) do
    str
    |> String.trim()
    |> String.split(")")
    |> Enum.reduce(fn orbiting, orbited ->
      [orbited, orbiting, {orbited, orbiting}]
    end)
  end
end
