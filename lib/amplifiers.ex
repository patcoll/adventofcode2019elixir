defmodule Amplifiers do
  @doc """
  """
  def run_permutation(
        %Program{code: code} = program,
        permutation,
        ampilifer_count \\ 1,
        feedback_mode \\ false
      ) do
    amps =
      1..ampilifer_count
      |> Enum.map(fn _ -> %Program{code: program.code} end)
      |> Enum.with_index()
      |> Enum.map(fn {amp, i} ->
        amp |> Program.with_input(Enum.at(permutation, i))
      end)

    amp_set = %{
      permutation: permutation,
      amplifiers: amps,
      input: 0
    }

    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while(amp_set, fn i, amp_set ->
      amp_number = rem(i, ampilifer_count)
      # |> IO.inspect(label: "i")

      # amp_set
      # |> IO.inspect(label: "amp_set")

      amp_set.input
      # |> IO.inspect(label: "input")

      maybe_mark_as_finished = fn program, feedback_mode ->
        if feedback_mode === false do
          %{program | finished: true}
        else
          program
        end
      end

      amp_as_ran =
        amp_set.amplifiers
        |> Enum.at(amp_number)
        |> Program.with_input(amp_set.input)
        |> Program.run()
        |> maybe_mark_as_finished.(feedback_mode)

      # |> IO.inspect(label: "amp_as_ran")

      amp_set_modified = %{
        amp_set
        | amplifiers: amp_set.amplifiers |> List.replace_at(amp_number, amp_as_ran),
          input:
            amp_as_ran
            |> Program.output()
          # |> IO.inspect(label: "output")
      }

      # |> IO.inspect(label: "amp_set_modified")

      # :timer.sleep(500)

      finished =
        amp_set_modified.amplifiers
        |> Enum.all?(&(&1.finished === true))

      # |> IO.inspect(label: "all finished?")

      # if all amplifiers are not finished
      if !finished do
        # if i < 25 do
        {:cont, amp_set_modified}
      else
        # if all amplifiers are finished
        # halt with output
        {:halt, {amp_set_modified.permutation, amp_set_modified.input}}
      end
    end)
  end

  @doc """
  iex> %Program{code: [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0]}
  ...> |> Amplifiers.find_best_phase_settings(5)
  {[4,3,2,1,0], 43210}
  """
  @spec find_best_phase_settings(%Program{}, integer) :: {[integer], integer}
  def find_best_phase_settings(
        %Program{code: code} = program,
        ampilifer_count \\ 1,
        feedback_mode \\ false
      )
      when is_integer(ampilifer_count) and ampilifer_count > 0 do
    phase_range =
      if feedback_mode === true do
        5..(5 + ampilifer_count - 1)
      else
        0..(ampilifer_count - 1)
      end

    phase_range
    |> Enum.to_list()
    |> Permutations.permutations()
    # |> IO.inspect(label: "permutations")
    |> Enum.map(&run_permutation(program, &1, ampilifer_count, feedback_mode))
    # |> IO.inspect(label: "permutation results", limit: :infinity)
    |> Enum.max_by(fn {_, output} -> output end)
  end
end
