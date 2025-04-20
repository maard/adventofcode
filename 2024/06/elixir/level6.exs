defmodule Main do
  def main() do
    parts()
  end

  def parts() do
    map = load_map()

    {x, y, direction} = find_guard(map)

    wm = walked_map(map, x, y, direction)

    num_walked =
    wm |> Enum.reduce(0, fn row, acc ->
      acc + Enum.count(row, fn cell -> cell == "X" end)
    end)

    IO.puts(num_walked)

    walked_cells = wm
    |> Enum.with_index()
    |> Enum.reduce([], fn {row, y}, acc ->
      Enum.with_index(row)
      |> Enum.reduce(acc, fn {cell, x}, acc ->
        if cell == "X" do
          [{x, y} | acc]
        else
          acc
        end
      end)
    end)
    walked_cells = walked_cells - [{x, y}]

    walked_cells
    |> Enum.reduce_while({x, y}, fn {x, y}, {last_x, last_y} ->
      if x == last_x && y == last_y do
        {:halt, {x, y}}
      else
        {:cont, {x, y}}
      end
    end)


  end

  def walked_map(map, x, y, direction) do
    Enum.reduce_while(1..(Enum.count(map) * Enum.count(hd(map))), {map, x, y, direction}, fn _, {map, x, y, direction} ->
      {map, x, y, direction, exited} = step(map, x, y, direction)
      case exited do
        true -> {:halt, {map, x, y, direction}}
        false -> {:cont, {map, x, y, direction}}
      end
    end)
    |> elem(0)
  end

  def find_guard(map) do
    map
    |> Enum.with_index()
    |> Enum.find_value(fn {row, y} ->
      Enum.with_index(row)
      |> Enum.find_value(fn {cell, x} ->
        case cell do
          "^" -> {x, y, :up}
          "v" -> {x, y, :down}
          "<" -> {x, y, :left}
          ">" -> {x, y, :right}
          _ -> nil
        end
      end)
    end)
  end

  def step(map, x, y, direction) do
    {dx, dy} = direction_to_vector(direction)
    # {map, x, y, direction, exited} = move_to(map, x, y, dx, dy, direction)
    move_to(map, x, y, dx, dy, direction)
  end

  def char_at(map, x, y) do
    Enum.at(Enum.at(map, y), x)
  end

  def move_to(map, x, y, dx, dy, direction) do
    map = replace_cell(map, x, y, "X")
    exited = case {x, y, direction} do
      {0, _, :left} -> true
      {_, 0, :up} -> true
      {x, _, :right} -> x == Enum.count(Enum.at(map, 0)) - 1
      {_, y, :down} -> y == Enum.count(map) - 1
      _ -> false
    end
    # IO.inspect({x, y, dx, dy, direction, exited})
    if !exited && char_at(map, x + dx, y + dy) == "#" do
      {map, x, y, turn(direction), exited}
    else
      {map, x + dx, y + dy, direction, exited}
    end
  end

  def replace_cell(map, x, y, v) do
    new_row = Enum.at(map, y) |> List.replace_at(x, v)
    List.replace_at(map, y, new_row)
  end

  def direction_to_vector(:up), do: {0, -1}
  def direction_to_vector(:right), do: {1, 0}
  def direction_to_vector(:down), do: {0, 1}
  def direction_to_vector(:left), do: {-1, 0}

  def turn(direction) do
    case direction do
      :up -> :right
      :right -> :down
      :down -> :left
      :left -> :up
    end
  end

  def load_map() do
    [filename] = System.argv()
    File.read!(filename)
    |> String.split(~r/\r?\n/)
    |> Enum.map(&String.split(&1, "", trim: true))
  end
end

Main.main()
