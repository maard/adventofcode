defmodule Main do
  def main() do
    # part1()
    part2()
  end

  def part1() do
    [filename] = System.argv()
    line = File.read!(filename)

    result = Regex.scan(~r/mul\((\d{1,3}),(\d{1,3})\)/, line)
    |> Enum.map(fn [_, a, b] -> String.to_integer(a) * String.to_integer(b) end)
    |> Enum.reduce(&+/2)

    IO.puts(result)
  end

  def part2() do
    [filename] = System.argv()
    line = File.read!(filename)

    result = Regex.scan(~r/mul\((\d{1,3}),(\d{1,3})\)|(do\(\))|(don't)(?:\(\))/, line)
    |> Enum.reduce({1, 0}, fn captures, {mul, sum} -> mul_prod(mul, sum, captures) end)
    |> elem(1)

    IO.puts(result)
  end

  def mul_prod(mul, sum, captures) do
    op = hd(captures)
    case op do
      "do()" -> {1, sum}
      "don't()" -> {0, sum}
      _ -> {mul, mul * mul(captures) + sum}
    end
  end

  def mul(captures) do
    [_, a, b] = captures
    String.to_integer(a) * String.to_integer(b)
  end

end

Main.main()
