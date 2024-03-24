defmodule FizzBuzz do

  def main() do
    Enum.each(1..100, &fizzbuzz/1)
  end

  @spec fizzbuzz(integer()) :: String.t()
  def fizzbuzz(number) do
    cond do
      rem(number, 3) == 0 and rem(number, 5) == 0 -> "FizzBuzz"
      rem(number, 3) == 0 -> "Fizz"
      rem(number, 5) == 0 -> "Buzz"
      true -> to_string(number)
    end
  end

end
