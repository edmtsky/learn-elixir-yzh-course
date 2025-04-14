defmodule WorkReport.Formatter do
  @spec format_time(integer) :: String.t()
  def format_time(time) do
    hours = div(time, 60)
    minutes = rem(time, 60)

    case {hours, minutes} do
      {0, 0} -> "0"
      {h, 0} -> "#{h}h"
      {0, m} -> "#{m}m"
      {h, m} -> "#{h}h #{m}m"
    end
  end
end
