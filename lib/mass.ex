defmodule Mass do
  @type name :: String.t()

  @enforce_keys [:name]
  defstruct [:name]
end
