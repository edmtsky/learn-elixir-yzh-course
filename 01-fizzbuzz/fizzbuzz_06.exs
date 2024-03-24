defmodule FizzBuzz do

  def main() do
    fizzbuzz_100()
    |> Enum.join(" ")
    |> IO.puts()
  end

  def fizzbuzz_100() do
    Enum.map(1..100, &fizzbuzz/1)
  end

  @spec fizzbuzz(integer()) :: String.t()
  def fizzbuzz(number) do
    divisible_by_3 = rem(number, 3) == 0
    divisible_by_5 = rem(number, 5) == 0
    cond do
      divisible_by_3 and divisible_by_5  -> "FizzBuzz"
      divisible_by_3 -> "Fizz"
      divisible_by_5 -> "Buzz"
      true -> to_string(number)
    end
  end

end


ExUnit.start()

defmodule FizzBuzzTest do
  use ExUnit.Case
  import FizzBuzz

  test "fizzbuzz 1-10" do
    assert fizzbuzz(1) == "1"
    assert fizzbuzz(2) == "2"
    assert fizzbuzz(3) == "Fizz"
    assert fizzbuzz(4) == "4"
    assert fizzbuzz(5) == "Buzz"
    assert fizzbuzz(6) == "Fizz"
    assert fizzbuzz(7) == "7"
    assert fizzbuzz(8) == "8"
    assert fizzbuzz(9) == "Fizz"
    assert fizzbuzz(10) == "Buzz"
  end

  test "fizzbuzz for sume numbers > 10" do
    assert fizzbuzz(11) == "11"
    assert fizzbuzz(12) == "Fizz"
    assert fizzbuzz(15) == "FizzBuzz"
    assert fizzbuzz(16) == "16"
    assert fizzbuzz(20) == "Buzz"
    assert fizzbuzz(30) == "FizzBuzz"
  end

  test "fizbuzz_100" do
    result = fizzbuzz_100()
    assert Enum.take(result, 5 ) == ["1", "2", "Fizz", "4", "Buzz"]
    assert Enum.at(result, 10) == "11"
    assert Enum.at(result, 15) == "16"
    assert Enum.at(result, 25) == "26"
    assert Enum.at(result, 50) == "Fizz"
    assert Enum.at(result, 70) == "71"
    assert Enum.at(result, 89) == "FizzBuzz"
    assert Enum.at(result, 90) == "91"
    assert Enum.at(result, 94) == "Buzz"
    assert Enum.at(result, 96) == "97"
    assert Enum.at(result, 99) == "Buzz"
  end
end

