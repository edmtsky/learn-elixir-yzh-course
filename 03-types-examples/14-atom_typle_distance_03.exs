defmodule AtomTupleExample do

  def distance({:point, x1, y1}, {:point, x2, y2}) do
    x_dist = x1 - x2
    y_dist = y1 - y2

    :math.pow(x_dist, 2) + :math.pow(y_dist, 2)
    |> :math.sqrt()
  end

  def point_inside_circle?(point, {:circle, center, radius}) do
    distance(point, center) <= radius
  end

  def point_inside_rect?({:point, x, y}, {:rect, left_top, righ_bottom}) do
    {:point, left_x, top_y} = left_top
    {:point, right_x, bottom_y} = righ_bottom
    x >= left_x and x <= right_x and y >= bottom_y and y <= top_y
  end
end


ExUnit.start()

defmodule AtomTupleExampleTest do
  use ExUnit.Case
  import AtomTupleExample

  test "distance" do
    assert distance({:point, 0, 0}, {:point, 0, 100}) == 100.0
    assert distance({:point, 0, 0}, {:point, 100, 0}) == 100.0
    assert distance({:point, 0, 0}, {:point, 3, 4}) == 5.0
  end
end

# AtomTupleExample.point_inside_circle?({:point,3,3}, {:circle, {:point,0,0}, 10})
# AtomTupleExample.point_inside_circle?({:point,13,3}, {:circle, {:point,0,0}, 10})


# AtomTupleExample.point_inside_rect?({:point, 5, 5}, {:rect, {:point, 0, 10}, {:point, 10, 0}})
# AtomTupleExample.point_inside_rect?({:point, 5, 15}, {:rect, {:point, 0, 10}, {:point, 10, 0}})
