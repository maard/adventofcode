defmodule Main do
  def main() do
    part1()
    part2()
  end

  def part1() do
    [filename] = System.argv()

    File.read!(filename)
    |> String.split(~r/\r?\n/, trim: true)
    |> Enum.map(&Regex.split(~r/\s+/, &1))
    |> Enum.reduce({[], []}, fn([a, b], {list1, list2}) -> {list1 ++ [a], list2 ++ [b]} end)
    |> Tuple.to_list()
    |> Enum.map(&Enum.sort(&1))
    |> Enum.zip_reduce(0, fn(pair, acc) -> acc + abs(integer_at_index(pair, 0) - integer_at_index(pair, 1)) end)
    |> IO.puts()
  end

  def part2() do
    [filename] = System.argv()

    {list0, list1} = File.read!(filename)
    |> String.split(~r/\r?\n/, trim: true)
    |> Enum.map(&Regex.split(~r/\s+/, &1))
    |> Enum.reduce({[], []}, fn([a, b], {list1, list2}) -> {list1 ++ [a], list2 ++ [b]} end)

    counts = Enum.reduce(list1, %{}, fn(x, acc) -> Map.update(acc, x, 1, &(&1 + 1)) end)

    list0 |> Enum.reduce(0, fn(el, acc) -> acc + String.to_integer(el) * Map.get(counts, el, 0) end) |> IO.puts()
  end

  def integer_at_index(list, index) do
    list
    |> Enum.at(index)
    |> String.to_integer()
  end
end

Main.main()
