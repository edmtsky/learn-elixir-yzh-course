defmodule AtomTupleExample do

  def distance({:point, x1, y1}, {:point, x2, y2}) do
    x_dist = x1 - x2
    y_dist = y1 - y2

    :math.pow(x_dist, 2) + :math.pow(y_dist, 2)
    |> :math.sqrt()
  end

  def point_inside_figure?(point, {:circle, center, radius}) do
    distance(point, center) <= radius
  end

  def point_inside_figure?({:point, x, y}, {:rect, left_top, righ_bottom}) do
    {:point, left_x, top_y} = left_top
    {:point, right_x, bottom_y} = righ_bottom
    dbg(left_x)
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

  test "point inside circle" do
    point = {:point, 50, 50}
    assert point_inside_figure?(point, {:circle, {:point, 10, 10}, 100})
    assert not point_inside_figure?(point, {:circle, {:point, -10, -10}, 20})
  end

  test "point inside rect" do
    point = {:point, -10, 20}
    assert point_inside_figure?(point, {:rect, {:point, -20, 30}, {:point, 20, 10}})
    assert not point_inside_figure?(point, {:rect, {:point, 0, 0}, {:point, 10, 10}})
  end

  test "invalid arguments for distance" do
    assert_raise FunctionClauseError, fn -> distance({0,0}, {0,5}) end
  end

  test "invalid arguments for inside figure" do
    assert_raise ArithmeticError, fn ->
      point_inside_figure?({:point, 1, 1}, {:circle, {:point,"5", "5"}, 10})
    end
  end
end

# AtomTupleExample.point_inside_figure?({:point,3,3}, {:circle,{:point,0,0},10})
# AtomTupleExample.point_inside_figure?({:point,13,3}, {:circle,{:point,0,0},10})

# AtomTupleExample.point_inside_figure?({:point,5,5}, {:rect,{:point,0,10},{:point,10,0}})
# AtomTupleExample.point_inside_figure?({:point,5,15}, {:rect,{:point,0,10},{:point,10,0}})


# AtomTupleExample.distance({:point, 0, 0}, {:point, "5", "5"})
# ** (ArithmeticError) bad argument in arithmetic expression: 0 - "5"
#     :erlang.-(0, "5")
#     atom-typle-distance-04.exs:4: AtomTupleExample.distance/2


# AtomTupleExample.point_inside_figure?({:point, 3, 3}, {:triangle, {:point, 0, 0}, {:point, 5, 5}, {:point, 0, 5}})
# ** (FunctionClauseError) no function clause matching in AtomTupleExample.point_inside_figure?/2
#
#     The following arguments were given to AtomTupleExample.point_inside_figure?/2:
#         # 1
#         {:point, 3, 3}
#         # 2
#         {:triangle, {:point, 0, 0}, {:point, 5, 5}, {:point, 0, 5}}
#
#     atom-typle-distance-04.exs:11: AtomTupleExample.point_inside_figure?/2
