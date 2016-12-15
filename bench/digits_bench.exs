defmodule Number.Format.Test do
  use Benchfella

  @number [1,2,3,4,5,6,7,8,9]
  @length length(@number)
  @first 3
  @group_separator ","

  bench "Reduce method" do
    split_point = @length - (div(@length, @first) * @first)
    {first_group, rest} = Enum.split(@number, split_point)

    {_, [_ | rest]} = Enum.reduce rest, {1, []}, fn elem, {counter, list} ->
      list = [elem | list]
      list = if rem(counter, @first) == 0 do
        [@group_separator | list]
      else
        list
      end
      {counter + 1, list}
    end

    case first_group do
      [] -> Enum.reverse(rest)
      _  -> [first_group, @group_separator, Enum.reverse(rest)]
    end
  end

  bench "Chunk method" do
    split_point = @length - (div(@length, @first) * @first)
    {first_group, rest} = Enum.split(@number, split_point)

    case [first_group] ++ Enum.chunk(rest, @first, @first) do
      [[], tail] ->
        tail
      [[] | tail] ->
        add_decimal_separators(tail, @group_separator)
      [head | tail] ->
        [head | add_decimal_separators(tail, @group_separator)]
    end
  end

  def add_decimal_separators([], _separator) do
    []
  end

  def add_decimal_separators([last | []], separator) do
    [separator, last]
  end

  def add_decimal_separators([first, second | []], separator) do
    [first, separator, second]
  end

  def add_decimal_separators([first, second | tail], separator) do
    [first, separator, second, add_decimal_separators(tail, separator)]
  end

  defp add_last_group(groups, [], _separator) do
    groups
  end

  defp add_last_group(groups, last, separator) do
    [groups, separator, last]
  end

end