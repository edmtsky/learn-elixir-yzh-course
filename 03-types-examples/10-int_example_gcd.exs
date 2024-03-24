defmodule GCD do
  @moduledoc """
  Own implementation of the  Greatest Common Divisor
  """

  def gcd(a, b) when a < 0, do: gcd(-a, b)

  def gcd(a, b) when b < 0, do: gcd(a, -b)

  def gcd(a, 0), do: a

  def gcd(a, b) do
    case rem(a, b) do
      0 -> b
      c -> gcd(b, c)
    end
  end

end

# tests

ExUnit.start()

defmodule GCDTest do
  use ExUnit.Case
  import GCD  # GCD.gcd()

  test "gcd base cases" do
    assert gcd(12, 9) == 3
    assert gcd(9, 12) == 3
    assert gcd(60,48) == 12
  end

  test "gcd with negative arguments" do
    assert gcd(24, 18) == 6
    assert gcd(-24, 18) == 6
    assert gcd(24, -18) == 6
    assert gcd(-24, -18) == 6
  end

  test "gcd with zero arguments" do
    assert gcd(5, 0) == 5
    assert gcd(0, 5) == 5
    assert gcd(0, 0) == 0
  end

end
