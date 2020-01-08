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

    {status, output, new_index} =
      case opcode_number do
        # add
        1 ->
          result_index = input |> Enum.at(index + 3)

          result =
            input
            |> Enum.slice(index + 1, 2)
            |> Enum.map(&Enum.at(input, &1, 0))
            |> Enum.sum()

          {:ok, List.replace_at(input, result_index, result), index + 4}

        # multiply
        2 ->
          result_index = input |> Enum.at(index + 3)

          result =
            input
            |> Enum.slice(index + 1, 2)
            |> Enum.map(&Enum.at(input, &1, 0))
            |> Enum.reduce(&*/2)

          {:ok, List.replace_at(input, result_index, result), index + 4}

        # halt
        99 ->
          {:halt, input, nil}
      end

    case status do
      :ok ->
        run(output, new_index)

      :halt ->
        output
    end
  end

  def run_to_get_output(input, desired_output)
      when is_list(input) and is_integer(desired_output) do
    options = for i <- 0..99, j <- 0..99, do: {i, j}

    result =
      options
      |> Enum.find(fn {i, j} ->
        code =
          input
          |> List.replace_at(1, i)
          |> List.replace_at(2, j)

        run(code) |> Enum.at(0) == desired_output
      end)

    case result do
      {_, _} ->
        {:ok, result}

      _ ->
        {:error, nil}
    end
  end

  def run_to_get_output2(input, desired_output)
      when is_list(input) and is_integer(desired_output) do
    result =
      Permutations.shuffle(0..99, 2)
      |> Enum.find(fn [i, j] ->
        code =
          input
          |> List.replace_at(1, i)
          |> List.replace_at(2, j)

        run(code) |> Enum.at(0) == desired_output
      end)

    case result do
      [i, j] ->
        {:ok, {i, j}}

      _ ->
        {:error, nil}
    end
  end
end
