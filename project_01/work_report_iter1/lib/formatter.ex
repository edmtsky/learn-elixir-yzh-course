defmodule WorkReport.Formatter do
  alias WorkReport.Model.Report
  alias WorkReport.Model.Month
  # alias WorkReport.Model.Day
  alias WorkReport.Model.Task

  @spec format_time(integer()) :: String.t()
  def format_time(minutes) when not is_integer(minutes) or minutes <= 0 do
    "0"
  end

  def format_time(minutes) when is_integer(minutes) and minutes < 60 and minutes > 0 do
    "#{minutes}m"
  end

  # >= 60 when is_integer(minutes) do and minutes > 0 do
  def format_time(minutes) do
    hours = div(minutes, 60)
    remaining_minutes = rem(minutes, 60)

    case remaining_minutes do
      0 -> "#{hours}h"
      _ -> "#{hours}h #{remaining_minutes}m"
    end
  end

  @doc """
  `[DEV] Review Pull Requests - 27m`
  """
  @spec format_task(Task.t()) :: String.t()
  def format_task(task) do
    ctg_name = to_string(task.category) |> String.upcase()
    " - #{ctg_name}: #{task.description} - #{format_time(task.time)}"
  end

  @doc """
  """
  @spec format_report(Report.t()) :: [String.t()]
  def format_report(report) do
    day_num = Integer.to_string(report.day.num, 10) |> String.pad_leading(2, "0")
    day_short_name = to_string(report.day.day_of_week) |> String.slice(0, 3)
    # minutes
    day_total = report.day_totals
    month_name = to_string(report.month_name) |> String.capitalize()
    # map + total-time, days_cnt, avg
    month_totals = report.month_totals

    day_tasks_lines =
      report.day.tasks
      |> Enum.reverse()
      |> Enum.map(fn task ->
        "#{format_task(task)}"
      end)

    [
      "Day: #{day_num} #{day_short_name}",
      day_tasks_lines,
      "   Total: #{format_time(day_total)}",
      "",
      "Month: #{month_name}",
      format_categories(month_totals.categories_time),
      format_month_totals(month_totals),
      ""
      # "",
    ]
    |> flatten_list()
    |> Enum.join("\n")

    # |> dbg()
  end

  @spec format_categories(map()) :: [String.t()]
  def format_categories(categories_time) do
    Enum.map(Task.known_categories(), fn ctg_name ->
      case Map.fetch(categories_time, ctg_name) do
        {:ok, time} ->
          ctg = to_string(ctg_name) |> String.upcase()
          " - #{ctg}: #{format_time(time)}"

        _ ->
          "?"
      end
    end)
  end

  @spec format_month_totals(Month.t()) :: String.t()
  def format_month_totals(month) do
    total_time = format_time(month.total_time)
    avg = format_time(month.avg_day_time)
    "   Total: #{total_time}, Days: #{month.days_cnt}, Avg: #{avg}"
  end

  # ["ab", ["c", "d"], "e"] --> ["ab", "c", "d", "e"]
  defp flatten_list(list) do
    Enum.flat_map(list, fn
      sublist when is_list(sublist) -> flatten_list(sublist)
      item -> [item]
    end)
  end
end
