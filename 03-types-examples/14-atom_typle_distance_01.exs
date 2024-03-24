defmodule AtomTupleExample do

  def distance(point1, point2) do
    {:point, x1, y1} = point1
    {:point, x2, y2} = point2
    x_dist = x1 - x2
    y_dist = y1 - y2

    # :math.sqrt(:math.pow(x_dist, 2) + :math.pow(y_dist, 2))
    :math.pow(x_dist, 2) + :math.pow(y_dist, 2)
    |> :math.sqrt()
  end
end


ExUnit.start()

defmodule AtomTupleExampleTest do
  use ExUnit.Case
  import AtomTupleExample  # Distance

  test "distance" do
    assert distance({:point, 0, 0}, {:point, 0, 100}) == 100.0
    assert distance({:point, 0, 0}, {:point, 100, 0}) == 100.0
    assert distance({:point, 0, 0}, {:point, 3, 4}) == 5.0
  end

end
