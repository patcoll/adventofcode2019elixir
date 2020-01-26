defmodule AmplifierSet do
  defstruct program: %Program{},
            amplifiers: [%Program{}],
            amplifier_count: 1,
            value: 0,
            feedback_mode: false

  def new(program, %{} = params \\ %{}) do
    amp_set = struct!(AmplifierSet, Map.merge(%{program: program}, params))

    amps =
      1..amp_set.amplifier_count
      |> Enum.map(fn _ -> %Program{code: program.code} end)

    %{amp_set | amplifiers: amps}
  end

  @doc """
  """
  def run_permutation(
        %AmplifierSet{} = amp_set,
        permutation
      ) do
    initialized_amplifiers =
      amp_set.amplifiers
      |> Enum.with_index()
      |> Enum.map(fn {amp, i} ->
        amp |> Program.with_input(Enum.at(permutation, i))
      end)

    amp_set = %{amp_set | amplifiers: initialized_amplifiers}

    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while(amp_set, fn i, amp_set ->
      amp_number = rem(i, amp_set.amplifier_count)

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
        |> Program.with_input(amp_set.value)
        |> Program.run()
        |> maybe_mark_as_finished.(amp_set.feedback_mode)

      amp_set_modified = %{
        amp_set
        | amplifiers: amp_set.amplifiers |> List.replace_at(amp_number, amp_as_ran),
          value: amp_as_ran |> Program.output()
      }

      finished =
        amp_set_modified.amplifiers
        |> Enum.all?(&(&1.finished === true))

      if !finished do
        {:cont, amp_set_modified}
      else
        {:halt, {permutation, amp_set_modified.value}}
      end
    end)
  end

  def find_best_phase_settings(%AmplifierSet{} = amp_set) do
    phase_range =
      if amp_set.feedback_mode === true do
        5..(5 + amp_set.amplifier_count - 1)
      else
        0..(amp_set.amplifier_count - 1)
      end

    phase_range
    |> Enum.to_list()
    |> Permutations.permutations()
    |> Enum.map(&run_permutation(amp_set, &1))
    |> Enum.max_by(fn {_, output} -> output end)
  end
end
