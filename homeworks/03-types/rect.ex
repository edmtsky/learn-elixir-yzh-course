defmodule Rect do
  @moduledoc """
  Work with rectangles
  """

  @type point() :: {:point, integer, integer}
  @type rect() :: {:rect, left_top_point: point(), right_bottom_point: point()}

  @doc """
  the `intersect/2` function takes two rectangles and returns
  `true` if the rectangles intersect, and `false` if they do not intersect.
  A rectangle is represented as `{:rect, left_top_point, right_bottom_point}`,
  points are represented by `{:point, x, y}` tuples.
  A mathematical coordinate system is used, where the point `{:point, 0, 0}` is
  in the lower left corner, the Y axis goes from bottom to top, and
  the X axis goes from left to right.

  ## Examples
  """
  @spec intersect(rect(), rect()) :: boolean
  def intersect(
        {:rect, left_top_1, right_bottom_1} = rect1,
        {:rect, left_top_2, right_bottom_2} = rect2
      ) do
    if not valid_rect(rect1) do raise "invalid rect 1" end
    if not valid_rect(rect2) do raise "invalid rect 2" end

    {:point, x1l, y1t} = left_top_1
    {:point, x1r, y1b} = right_bottom_1

    {:point, x2l, y2t} = left_top_2
    {:point, x2r, y2b} = right_bottom_2

    y_not_intersects = y1t < y2b || y1b > y2t
    x_not_intersects = x1r < x2l || x1l > x2r

    not y_not_intersects and not x_not_intersects
  end


  @doc """
   `valid_rect/1` determines whether the given rectangle is valid.
   A rectangle is valid if the `left_top` point is above and to the left of
   the `right_bottom` point.
  """
  @spec valid_rect(rect()) :: boolean
  def valid_rect({:rect, left_top, right_bottom}) do
    {:point, xl, yt} = left_top
    {:point, xr, yb} = right_bottom
    xl < xr and yb < yt
  end

end
