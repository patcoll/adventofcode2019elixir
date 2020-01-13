defmodule Program do
  defstruct code: [%Opcode{}.number], pos: 0, input: [], output: []

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
  iex> Program.run_code([1002,4,3,4,33]).code |> Enum.at(4)
  99
  iex> Program.run_code([1101,100,-1,4,0]).code |> Enum.at(4)
  99
  """
  def run_code(code) when is_list(code) do
    %Program{code: code} |> run
  end

  def with_input(program, num) when is_integer(num) do
    %{program | input: program.input ++ [num]}
  end

  def output(program) do
    program.output |> List.last()
  end

  @doc """
  iex> %Program{code: [3,0,4,0,99], input: [2000]} |> Program.run |> Program.output
  2000
  iex> %Program{code: [4,0,99]} |> Program.run |> Program.output
  4
  """
  def run(program) do
    opcode_number = program.code |> Enum.at(program.pos)
    opcode = Opcode.from(opcode_number, program.pos)

    {status, program} =
      case opcode.number do
        # add
        1 ->
          [_, _, result_index] = Opcode.indexes(opcode, program)
          [first, second | _] = Opcode.values(opcode, program)
          result = first + second

          code =
            program.code
            |> List.replace_at(result_index, result)

          {
            :cont,
            %{program | code: code, pos: program.pos + opcode.length}
          }

        # multiply
        2 ->
          [_, _, result_index] = Opcode.indexes(opcode, program)
          [first, second | _] = Opcode.values(opcode, program)
          result = first * second

          code =
            program.code
            |> List.replace_at(result_index, result)

          {
            :cont,
            %{program | code: code, pos: program.pos + opcode.length}
          }

        # input
        3 ->
          [result_index] = Opcode.indexes(opcode, program)

          {value, new_input} = program.input |> List.pop_at(0)

          case value do
            nil ->
              {:halt, program}

            _ ->
              code =
                program.code
                |> List.replace_at(result_index, value)

              {:cont, %{program | code: code, pos: program.pos + opcode.length, input: new_input}}
          end

        # output
        4 ->
          [value] = Opcode.values(opcode, program)

          new_output = program.output ++ [value]

          {:cont, %{program | pos: program.pos + opcode.length, output: new_output}}

        # halt
        99 ->
          {:halt, program}
      end

    case status do
      :cont ->
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

        run_code(code).code |> Enum.at(0) == desired_output
      end)

    case result do
      {_, _} ->
        {:ok, result}

      _ ->
        {:error, nil}
    end
  end
end
