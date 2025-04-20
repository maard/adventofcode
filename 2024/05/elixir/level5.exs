defmodule Main do
  def main() do
    # part1()
    part2()
  end

  def part1() do
    {map, lists} = load_data()

    Enum.filter(lists, fn pages ->
      Enum.reduce(0..(length(pages)-2), true, fn i, acc ->
        Enum.reduce((i+1)..(length(pages)-1), acc, fn j, acc ->
          acc && (Enum.member?(Map.get(map, Enum.at(pages, i), []), Enum.at(pages, j)))
        end)
      end)
    end)
    |> sum_middle()
    |> IO.inspect()
  end

  def part2() do
    {map, lists} = load_data()

    Enum.reject(lists, fn pages ->
      Enum.reduce(0..(length(pages)-2), true, fn i, acc ->
        Enum.reduce((i+1)..(length(pages)-1), acc, fn j, acc ->
          acc && (Enum.member?(Map.get(map, Enum.at(pages, i), []), Enum.at(pages, j)))
        end)
      end)
    end)
    |> Enum.map(fn pages ->
      # reorder
      Enum.reduce(0..(length(pages)-2), pages, fn i, acc ->
        Enum.reduce((i+1)..(length(pages)-1), acc, fn j, acc ->
          if !Enum.member?(Map.get(map, Enum.at(acc, i), []), Enum.at(acc, j)) do
            swap(acc, i, j)
          else
            acc
          end
        end)
      end)
    end)
    |> sum_middle()
    |> IO.inspect()
  end

  def swap(list, i, j) do
    el1 = Enum.at(list, i)
    el2 = Enum.at(list, j)
    List.replace_at(List.replace_at(list, j, el1), i, el2)
  end

  def sum_middle(lists) do
    lists
    |> Enum.reduce(0, fn pages, acc ->
        acc + String.to_integer(Enum.at(pages, trunc(length(pages)/2)))
    end)
  end

  def load_data() do
    [filename] = System.argv()
    lines = File.read!(filename)
    |> String.split(~r/\r?\n/)

    {pairs, lists} = Enum.split_while(lines, fn line -> line != "" end)
    lists = tl(lists)

    map = pairs
    |> Enum.reduce(%{}, fn s, acc ->
      [v1, v2] = String.split(s, "|")
      Map.update(acc, v1, [v2], fn v -> [v2 | v] end)
    end)

    lists = Enum.map(lists, fn line -> String.split(line, ",") end)

    {map, lists}
  end
end

Main.main()
