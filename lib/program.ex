defmodule Program do
  defstruct code: [99], pos: 0, input: [], output: []

  @doc """
  iex> Program.run_code([99]).pos
  0
  iex> Program.run(%Program{}).pos
  0
  iex> Program.run_code([1,0,0,0,99]).code |> Enum.at(0)
  2
  iex> Program.run_code([2,0,0,0,99]).code |> Enum.at(0)
  4
  iex> Program.run_code([1,9,10,3,2,3,11,0,99,30,40,50]).code |> Enum.at(0)
  3500
  """
  def run_code(code) when is_list(code) do
    %Program{code: code} |> run
  end

  def with_input(program, num) when is_integer(num) do
    %{program | input: program.input ++ [num]}
  end

  @doc """
  iex> (%Program{code: [3,0,4,0,99], input: [2000]} |> Program.run).output |> Enum.at(0)
  2000
  iex> (%Program{code: [4,0,99]} |> Program.run).output |> Enum.at(0)
  4
  """
  def run(program) do
    opcode_number = program.code |> Enum.at(program.pos)

    {status, program} =
      case opcode_number do
        # add
        1 ->
          result_index = program.code |> Enum.at(program.pos + 3)

          result =
            program.code
            |> Enum.slice(program.pos + 1, 2)
            # position mode
            # default of zero
            |> Enum.map(&Enum.at(program.code, &1, 0))
            |> Enum.sum()

          code =
            program.code
            |> List.replace_at(result_index, result)

          {
            :ok,
            %{program | code: code, pos: program.pos + 4},
          }

        # multiply
        2 ->
          result_index = program.code |> Enum.at(program.pos + 3)

          result =
            program.code
            |> Enum.slice(program.pos + 1, 2)
            # position mode
            # default of zero
            |> Enum.map(&Enum.at(program.code, &1, 0))
            |> Enum.reduce(&*/2)

          code =
            program.code
            |> List.replace_at(result_index, result)

          {
            :ok,
            %{program | code: code, pos: program.pos + 4},
          }
        3 ->
          result_index = program.code |> Enum.at(program.pos + 1)

          {value, new_input} = program.input |> List.pop_at(0)

          unless is_nil(value) do
            code =
              program.code
              |> List.replace_at(result_index, value)

            {:ok, %{program | code: code, pos: program.pos + 2, input: new_input}}
          else
            {:halt, program}
          end
        4 ->
          value_index = program.code |> Enum.at(program.pos + 1)

          # position mode
          # default of zero
          value = program.code |> Enum.at(value_index, 0)

          new_output = program.output ++ [value]

          {:ok, %{program | pos: program.pos + 2, output: new_output}}
        # halt
        99 ->
          {:halt, program}
      end

    case status do
      :ok ->
        run(program)

      :halt ->
        program
    end
  end

  def run_to_get_output(code, desired_output)
      when is_list(code) and is_integer(desired_output) do
    options = for i <- 0..99, j <- 0..99, do: {i, j}

    result =
      options
      |> Enum.find(fn {i, j} ->
        code =
          code
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
end
