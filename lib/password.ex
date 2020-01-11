defmodule Password do
  @doc """
  iex> Password.find_candidates(2..8) |> length
  0
  iex> Password.find_candidates(2..11) |> length
  1
  iex> Password.find_candidates(2..12) |> length
  1
  iex> Password.find_candidates(2..98) |> length
  8
  iex> Password.find_candidates(2..100) |> length
  9
  iex> Password.find_candidates(20..99) |> length
  8
  iex> Password.find_candidates(20..80) |> length
  6
  iex> Password.find_candidates(200..800) |> length
  60
  """
  @spec find_candidates(Range.t()) :: nonempty_list(integer)
  def find_candidates(range) do
    %Range{first: first, last: last} = range

    range
    |> start
    |> accumulate_candidates(last |> Integer.digits() |> length)
    |> Enum.filter(&has_adjacent_dup/1)
    |> Enum.map(&Integer.undigits/1)
    |> Enum.filter(&(&1 >= first && &1 <= last))
  end

  @doc """
  iex> Password.find_candidates_with_one_dup(2..8) |> length
  0
  iex> Password.find_candidates_with_one_dup(2..11) |> length
  1
  iex> Password.find_candidates_with_one_dup(2..12) |> length
  1
  iex> Password.find_candidates_with_one_dup(2..99) |> length
  9
  iex> Password.find_candidates_with_one_dup(2..100) |> length
  9
  iex> Password.find_candidates_with_one_dup(20..99) |> length
  8
  iex> Password.find_candidates_with_one_dup(20..80) |> length
  6
  iex> Password.find_candidates_with_one_dup(200..800) |> length
  54
  """
  def find_candidates_with_one_dup(range) do
    %Range{first: first, last: last} = range

    range
    |> start
    |> accumulate_candidates(last |> Integer.digits() |> length)
    |> Enum.filter(&has_one_adjacent_dup/1)
    |> Enum.map(&Integer.undigits/1)
    |> Enum.filter(&(&1 >= first && &1 <= last))
  end

  @doc """
  iex> Password.has_adjacent_dup([1,2,3])
  false
  iex> Password.has_adjacent_dup([2,2,3])
  true
  """
  def has_adjacent_dup(digits) do
    digits
    |> Enum.with_index()
    |> Enum.map(fn {n, i} ->
      prev = if i == 0, do: nil, else: digits |> Enum.at(i - 1)
      n === prev
    end)
    |> Enum.any?()
  end

  @doc """
  iex> Password.has_one_adjacent_dup([1,2,3])
  false
  iex> Password.has_one_adjacent_dup([2,2,3])
  true
  iex> Password.has_one_adjacent_dup([2,2,2])
  false
  iex> Password.has_one_adjacent_dup([8,9,8])
  false
  iex> Password.has_one_adjacent_dup([8,9,9])
  true
  """
  def has_one_adjacent_dup(digits) do
    counts = for _ <- 0..9, do: 0

    has_one_adjacent_dup =
      digits
      |> Enum.reduce(counts, fn digit, counts ->
        counts |> List.replace_at(digit, Enum.at(counts, digit) + 1)
      end)
      |> Enum.any?(&(&1 === 2))

    has_adjacent_dup(digits) && has_one_adjacent_dup
  end

  @doc """
  iex> Password.accumulate_candidates([[2], [3], [4]], 2)
  [[2], [3], [4], [2, 2], [2, 3], [2, 4], [2, 5], [2, 6], [2, 7], [2, 8], [2, 9], [3, 3], [3, 4], [3, 5], [3, 6], [3, 7], [3, 8], [3, 9], [4, 4], [4, 5], [4, 6], [4, 7], [4, 8], [4, 9]]
  """
  def accumulate_candidates(acc \\ [], length) do
    grown = acc |> grow

    cond do
      length == 1 ->
        []

      length(List.first(grown)) == length ->
        acc ++ grown

      true ->
        acc ++ accumulate_candidates(grown, length)
    end
  end

  @doc """
  iex> Password.grow([[2], [3], [4]])
  [[2, 2], [2, 3], [2, 4], [2, 5], [2, 6], [2, 7], [2, 8], [2, 9], [3, 3], [3, 4], [3, 5], [3, 6], [3, 7], [3, 8], [3, 9], [4, 4], [4, 5], [4, 6], [4, 7], [4, 8], [4, 9]]
  """
  def grow(input) when is_list(input) do
    input
    |> Enum.flat_map(fn prefix ->
      prefix
      |> Kernel.++([List.last(prefix)])
      |> generate_subsequent_numbers
    end)
  end

  @doc """
  iex> Password.generate_subsequent_numbers([2, 2])
  [[2, 2], [2, 3], [2, 4], [2, 5], [2, 6], [2, 7], [2, 8], [2, 9]]
  """
  def generate_subsequent_numbers([_, _ | _] = prefix) do
    index = length(prefix) - 1
    last = prefix |> Enum.at(index)

    last..9
    |> Enum.map(fn n ->
      prefix |> List.replace_at(index, n)
    end)
  end

  @doc """
  iex> Password.start(2..4)
  [[2], [3], [4]]
  iex> Password.start(4..12)
  [[1], [2], [3], [4], [5], [6], [7], [8], [9]]
  """
  def start(range) do
    %Range{first: first, last: last} = range

    first_digits = first |> Integer.digits()
    last_digits = last |> Integer.digits()

    if length(first_digits) == length(last_digits) do
      List.first(first_digits)..List.first(last_digits)
    else
      1..9
    end
    |> Enum.to_list()
    |> Enum.map(&[&1])
  end
end
