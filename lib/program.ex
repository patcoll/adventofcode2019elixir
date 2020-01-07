defmodule Program do
  @doc """

  ## Examples
  iex> Program.run([1,0,0,0,99]) |> Enum.at(0)
  2
  iex> Program.run([2,0,0,0,99]) |> Enum.at(0)
  4
  iex> Program.run([1,9,10,3,2,3,11,0,99,30,40,50]) |> Enum.at(0)
  3500

  """
  def run(input, index \\ 0) when is_list(input) and is_integer(index) do
    opcode_number = input |> Enum.at(index)

    {status, output, length} =
      case opcode_number do
        1 ->
          result_index = input |> Enum.at(index + 3)

          result =
            input
            |> Enum.slice(index + 1, 2)
            |> Enum.map(&Enum.at(input, &1, 0))
            |> Enum.sum()

          {:ok, List.replace_at(input, result_index, result), 4}

        2 ->
          result_index = input |> Enum.at(index + 3)

          result =
            input
            |> Enum.slice(index + 1, 2)
            |> Enum.map(&Enum.at(input, &1))
            |> Enum.reduce(1, &*/2)

          {:ok, List.replace_at(input, result_index, result), 4}

        99 ->
          {:halt, input, 1}
      end

    case status do
      :ok ->
        run(output, index + length)

      :halt ->
        output
    end
  end

  def run_to_get_output(input, desired_output)
      when is_list(input) and is_integer(desired_output) do
    0..99
    |> Enum.flat_map(fn i ->
      0..99
      |> Enum.map(fn j ->
        code =
          input
          |> List.replace_at(1, i)
          |> List.replace_at(2, j)

        case run(code) |> Enum.at(0) do
          o when o == desired_output ->
            {:ok, {i, j}}

          _ ->
            {:error, nil}
        end
      end)
    end)
    |> Enum.find(fn res ->
      case res do
        {:ok, _} -> true
        _ -> false
      end
    end)
  end
end
