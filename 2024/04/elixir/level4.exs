defmodule Main do
  def main() do
    # part1()
    part2()
  end

  def part1() do
    [filename] = System.argv()
    lines = File.read!(filename)
    |> String.split(~r/\r?\n/, trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))

    width = Enum.count(hd(lines))
    height = Enum.count(lines)

    verticals = lines
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)

    all_lists = lines ++ verticals
      ++ diag_coords_to_elements(diagonal_coord_lists1(width, height), lines)
      ++ diag_coords_to_elements(diagonal_coord_lists2(width, height), lines)
    all_lists = all_lists ++ Enum.map(all_lists, &Enum.reverse(&1))
    all_lists = Enum.map(all_lists, &Enum.join(&1))

    all_lists
    |> Enum.reduce(0, fn line, acc ->
      acc + (Regex.scan(~r/XMAS/, line) |> Enum.count())
    end)
    |> IO.puts()
  end

  def part2() do
    [filename] = System.argv()
    lines = File.read!(filename)
    |> String.split(~r/\r?\n/, trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))

    width = Enum.count(hd(lines))
    height = Enum.count(lines)

    Enum.map(0..(width-3), fn x ->
      Enum.map(0..(height-3), fn y ->
        int_mas(char_at(lines, x, y) <> char_at(lines, x+1, y+1) <> char_at(lines, x+2, y+2)) +
        int_mas(char_at(lines, x+2, y+2) <> char_at(lines, x+1, y+1) <> char_at(lines, x, y)) +
        int_mas(char_at(lines, x+2, y) <> char_at(lines, x+1, y+1) <> char_at(lines, x, y+2)) +
        int_mas(char_at(lines, x, y+2) <> char_at(lines, x+1, y+1) <> char_at(lines, x+2, y))
      end)
    end)
    |> List.flatten()
    |> Enum.filter(&(&1 == 2))
    |> Enum.count()
    |> IO.puts()
  end

  def int_mas(line) do
    if line == "MAS", do: 1, else: 0
  end

  def char_at(lines, x, y) do
    Enum.at(Enum.at(lines, y), x)
  end

  def diag_coords_to_elements(coord_lists, lines) do
    Enum.map(coord_lists, fn coords ->
      Enum.map(coords, fn {x, y} -> Enum.at(Enum.at(lines, y), x) end)
    end)
  end

  def diagonal_coord_lists1(width, height) do
    lists = Enum.map(1..(width + height - 1), fn i ->
      {x, y} = if i <= width do
        {width - i, 0}
      else
        {0, i - width}
      end
      # IO.puts(inspect({x, y}))
      Enum.reduce_while(0..(width + height), [], fn i, acc ->
        if x + i < width && y + i < height do
          {:cont, acc ++ [{x + i, y + i}]}
        else
          {:halt, acc}
        end
      end)
    end)
    lists
  end


  def diagonal_coord_lists2(width, height) do
    lists = Enum.map(1..(width + height - 1), fn i ->
      {x, y} = if i <= width do
        {i - 1, 0}
      else
        {width - 1, i - width}
      end
      # IO.puts(inspect({x, y}))
      Enum.reduce_while(0..(width + height), [], fn i, acc ->
        if x - i >= 0 && y + i < height do
          {:cont, acc ++ [{x - i, y + i}]}
        else
          {:halt, acc}
        end
      end)
    end)
    lists
  end
end

Main.main()
