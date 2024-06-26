defmodule QuadraticEquation do
  @moduledoc """
  https://en.wikipedia.org/wiki/Quadratic_equation
  """

  @doc """
  function accepts 3 integer arguments and returns:
  {:roots, root_1, root_2} or {:root, root_1} or :no_root

  ## Examples
  iex> QuadraticEquation.solve(1, -2, -3)
  {:roots, 3.0, -1.0}
  iex> QuadraticEquation.solve(3, 5, 10)
  :no_roots
  """
  def solve(a, b, c) do
    discremenant = b * b - (4 * a * c)
    cond do
      discremenant > 0 ->
        root1 = (- b + :math.sqrt(discremenant)) / (2 * a)
        root2 = (- b - :math.sqrt(discremenant)) / (2 * a)
        {:roots, root1, root2}

      discremenant == 0 ->
        root1 = - b / (2 * a)
        {:root, root1}

      discremenant < 0 ->
        :no_roots
    end
  end

end
