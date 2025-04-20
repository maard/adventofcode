defmodule Main do
  def main() do
    part1()
    part2()
  end

  def part1() do
    [filename] = System.argv()

    reports = load_integer_lists(filename)
    # IO.puts(inspect(reports))

    reduced = reports
    |> Enum.map(&int_list_to_deltas/1)
    |> Enum.filter(&safe_list?/1)

    IO.puts(length(reduced))
  end

  def part2() do
    [filename] = System.argv()

    reports = load_integer_lists(filename)

    reduced = reports
    |> Enum.filter(&almost_safe_list?/1)

    IO.puts(length(reduced))
  end

  def int_list_to_deltas(list_of_ints) do
    Enum.reduce(
      list_of_ints,
      [{nil, 0}],
      fn x, acc ->
        {prev, _} = List.last(acc)
        if is_nil(prev) do
          [{x, 0}]
        else
          acc ++ [{x, x - prev}]
        end
      end
    )
    |> tl()
    |> Enum.map(&elem(&1, 1))
  end

  def load_integer_lists(filename) do
    File.read!(filename)
    |> String.split(~r/\r?\n/, trim: true)
    |> Enum.map(&Regex.split(~r/\s+/, &1))
    |> Enum.map(fn list -> Enum.map(list, &String.to_integer/1) end)
  end

  def sign(n) do
    case n do
      n when n > 0 -> 1
      n when n < 0 -> -1
      _ -> 0
    end
  end

  def safe_list?(list) do
    Enum.all?(list, fn x -> 1 <= abs(x) && abs(x) <= 3 end) && num_same_sign(list) == length(list)
  end

  def almost_safe_list?(list) do
    0..length(list)-1
    |> Enum.any?(fn n -> List.delete_at(list, n) |> int_list_to_deltas() |> safe_list?() end)
  end

  def num_same_sign(list) do
    Enum.count(list, fn x -> sign(x) == sign(hd(list)) end)
  end
end

Main.main()
