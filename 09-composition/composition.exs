defmodule Composition do
  def f1(a) do
    a + 1
  end

  def f2(a) do
    a + 10
  end

  def f3(a, b) do
    a + b
  end

  def f4(a) do
    {:ok, a + 1}
  end

  def f5(a) when a < 10 do
    {:ok, a + 1}
  end

  def f5(a) do
    {:error}
  end

  def f6(a) do
    # drop_database() # side effect what changes something somewhere in the outside
    a + 42
  end
end

