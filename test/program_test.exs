defmodule ProgramTest do
  use ExUnit.Case
  doctest Program

  test :test_phase_settings do
    code = [3, 15, 3, 16, 1002, 16, 10, 16, 1, 16, 15, 15, 4, 15, 99, 0, 0]

    output =
      %Program{code: code, input: [4, 0]}
      |> Program.run()
      |> Program.output()

    assert output == 4

    output =
      %Program{code: code, input: [3, 4]}
      |> Program.run()
      |> Program.output()

    assert output == 43

    output =
      %Program{code: code, input: [2, 43]}
      |> Program.run()
      |> Program.output()

    assert output == 432

    output =
      %Program{code: code, input: [1, 432]}
      |> Program.run()
      |> Program.output()

    assert output == 4321

    output =
      %Program{code: code, input: [0, 4321]}
      |> Program.run()
      |> Program.output()

    assert output == 43210
  end

  test :test_phase_settings_2 do
    code = [
      3,
      31,
      3,
      32,
      1002,
      32,
      10,
      32,
      1001,
      31,
      -2,
      31,
      1007,
      31,
      0,
      33,
      1002,
      33,
      7,
      33,
      1,
      33,
      31,
      31,
      1,
      32,
      31,
      31,
      4,
      31,
      99,
      0,
      0,
      0
    ]

    output =
      %Program{code: code, input: [1, 0]}
      |> Program.run()
      |> Program.output()

    assert output == 6

    output =
      %Program{code: code, input: [0, 6]}
      |> Program.run()
      |> Program.output()

    assert output == 65

    output =
      %Program{code: code, input: [4, 65]}
      |> Program.run()
      |> Program.output()

    assert output == 652

    output =
      %Program{code: code, input: [3, 652]}
      |> Program.run()
      |> Program.output()

    assert output == 6521

    output =
      %Program{code: code, input: [2, 6521]}
      |> Program.run()
      |> Program.output()

    assert output == 65210

    # {permutation, output} =
    #   %Program{code: code}
    #   |> Amplifiers.find_best_phase_settings(5)
    #
    # assert permutation == [1, 0, 4, 3, 2]
    # assert output == 65210
  end

  test :find_best_phase_settings do
    code = [
      3,
      31,
      3,
      32,
      1002,
      32,
      10,
      32,
      1001,
      31,
      -2,
      31,
      1007,
      31,
      0,
      33,
      1002,
      33,
      7,
      33,
      1,
      33,
      31,
      31,
      1,
      32,
      31,
      31,
      4,
      31,
      99,
      0,
      0,
      0
    ]

    {permutation, output} =
      %Program{code: code}
      |> Amplifiers.run_permutation([1, 0, 4, 3, 2], 5, false)

    assert permutation == [1, 0, 4, 3, 2]
    assert output == 65210
  end

  test :find_best_phase_settings_2 do
    code = [
      3,
      23,
      3,
      24,
      1002,
      24,
      10,
      24,
      1002,
      23,
      -1,
      23,
      101,
      5,
      23,
      23,
      1,
      24,
      23,
      23,
      4,
      23,
      99,
      0,
      0
    ]

    program = %Program{code: code}

    {permutation, output} =
      program
      |> Amplifiers.run_permutation([0, 1, 2, 3, 4], 5, false)

    assert permutation == [0, 1, 2, 3, 4]
    assert output == 54321

    {permutation, output} =
      program
      |> Amplifiers.find_best_phase_settings(5, false)

    assert permutation == [0, 1, 2, 3, 4]
    assert output == 54321
  end

  test :test_phase_settings_in_feedback_mode do
    code = [
      3,
      26,
      1001,
      26,
      -4,
      26,
      3,
      27,
      1002,
      27,
      2,
      27,
      1,
      27,
      26,
      27,
      4,
      27,
      1001,
      28,
      -1,
      28,
      1005,
      28,
      6,
      99,
      0,
      0,
      5
    ]

    program = %Program{code: code}

    {permutation, output} =
      program
      |> Amplifiers.run_permutation([9, 8, 7, 6, 5], 5, true)

    assert permutation == [9, 8, 7, 6, 5]
    assert output == 139_629_729
  end

  test :find_best_phase_settings_in_feedback_mode do
    code = [
      3,
      26,
      1001,
      26,
      -4,
      26,
      3,
      27,
      1002,
      27,
      2,
      27,
      1,
      27,
      26,
      27,
      4,
      27,
      1001,
      28,
      -1,
      28,
      1005,
      28,
      6,
      99,
      0,
      0,
      5
    ]

    program = %Program{code: code}

    {permutation, output} =
      program
      |> Amplifiers.find_best_phase_settings(5, true)

    assert permutation == [9, 8, 7, 6, 5]
    assert output == 139_629_729
  end
end
