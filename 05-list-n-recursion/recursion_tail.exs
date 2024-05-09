defmodule Recursion do

  # The Seven Myths of Erlang Performance
  # https://www.erlang.org/doc/efficiency_guide/myths.html

  @moduledoc """
  Здесь на основе решения двух задач с разным типом создаваемой нагрузки
  рассматриваются особенности работы обычной и хвостовой рекурсии

  Задача 1 - факториал - генерирует много промежуточных данных которые очень
  быстро забивают память BEAM-а

  Задача 2 - подсчёт суммы элементов списка - не создаёт такого большого
  количества "мусора"


  iex recursion_tail.exs
  Erlang/OTP 26 [erts-14.2.4] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [jit:ns]

  Interactive Elixir (1.16.2) - press Ctrl+C to exit (type h() ENTER for help)

  iex(1)> spawn(Recursion, :factorial, [50_000])

  memory: 2640,   total_heap_size: 233,    stack_size: 4
  memory: 238192, total_heap_size: 29677,  stack_size: 20004
  memory: 380048, total_heap_size: 47409,  stack_size: 40004
  memory: 609576, total_heap_size: 76100,  stack_size: 60004
  memory: 980960, total_heap_size: 122523, stack_size: 80004


  iex(2)> spawn(Recursion, :factorial_t, [50_000])
  memory: 2640,      total_heap_size: 233,      stack_size: 5
  memory: 34992936,  total_heap_size: 4374020,  stack_size: 5
  memory: 129117992, total_heap_size: 16139652, stack_size: 5
  memory: 165907288, total_heap_size: 20738314, stack_size: 5
  memory: 200899008, total_heap_size: 25112279, stack_size: 5

  body         tail
  980_960  vs  200 899 008      205 times!
  """

  # task 1

  # body-recursion

  def factorial(0), do: 1

  def factorial(n) do
    if rem(n, 10_000) == 0, do: report_memory()

     res = factorial(n - 1)
     n * res
  end

  # tail recursion

  def factorial_t(n) do
    factorial_t(n, 1)
  end

  defp factorial_t(0, acc), do: acc

  defp factorial_t(n, acc) do
    if rem(n, 10_000) == 0, do: report_memory()

    curr_result = n * acc
    factorial_t(n - 1, curr_result)
  end

  def report_memory() do
    res = :erlang.process_info(self(), [:memory, :total_heap_size, :stack_size])
    dbg(res)
  end

  # task 2
  @doc """
  iex(1)> list = 1..100 |> Enum.to_list()

  iex(2)> spawn(Recursion, :sum_list, [list])
  [recursion_tail.exs:70: Recursion.report_memory/0]
  memory: 10536, total_heap_size: 1220, stack_size: 43
  memory: 34248, total_heap_size: 4184, stack_size: 83
  memory: 34248, total_heap_size: 4184, stack_size: 103
  ...
  memory: 42152, total_heap_size: 5172, stack_size: 203

  iex(3)> spawn(Recursion, :sum_list_t, [list])
  [recursion_tail.exs:70: Recursion.report_memory/0]
  memory: 21456, total_heap_size: 2585, stack_size: 6
  memory: 21456, total_heap_size: 2585, stack_size: 6
  memory: 21456, total_heap_size: 2585, stack_size: 6
  ...
  memory: 21456, total_heap_size: 2585, stack_size: 6

  body        tail
  42_152  vs  21_456
    5172        2585
    203            6
  """

  # body-recursion


  def sum_list([]), do: 0

  # def sum_lis(list) do
  def sum_list([head | tail]) do
    if rem(head, 10) == 0, do: report_memory()

    head + sum_list(tail)
  end


  # tail recursion

  def sum_list_t(list) do
    sum_list_t(list, 0)
  end

  defp sum_list_t([], acc), do: acc


  defp sum_list_t([head | tail], acc) do
    if rem(head, 10) == 0, do: report_memory()

    sum_list_t(tail, head + acc)
  end

end
