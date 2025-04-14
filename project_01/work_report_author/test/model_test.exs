defmodule ModelTest do
  use ExUnit.Case

  # alias WorkReport.Parser, as: P
  alias WorkReport.Model.{Report, Month, Day, Task}

  test "add day to report " do
    month1 = Month.new(1, "Jan")
    month2 = Month.new(2, "Feb")

    report =
      Report.new()
      |> Report.add_month(month1)
      |> Report.add_month(month2)

    assert report == %Report{months: [month1, month2]}

    day1 = Day.new(1, "1 mon")
    day2 = Day.new(2, "2 tue")
    report = Report.add_day(report, 1, day1)
    report = Report.add_day(report, 1, day2)

    day3 = Day.new(3, "3 wed")
    day4 = Day.new(4, "4 tru")
    report = Report.add_day(report, 2, day3)
    report = Report.add_day(report, 2, day4)

    assert report == %Report{
             months: [
               %Month{id: 1, description: "Jan", days: [day1, day2]},
               %Month{id: 2, description: "Feb", days: [day3, day4]}
             ]
           }
  end

  test "add task to report " do
    day1 = Day.new(1, "1 mon")
    day2 = Day.new(2, "2 tue")
    month1 = Month.new(1, "Jan") |> Month.add_day(day1) |> Month.add_day(day2)

    day3 = Day.new(3, "3 wed")
    day4 = Day.new(4, "4 tru")
    month2 = Month.new(2, "Feb") |> Month.add_day(day3) |> Month.add_day(day4)

    report = Report.new() |> Report.add_month(month1) |> Report.add_month(month2)

    task1 = Task.new("DEV", "some desc", 30)
    task2 = Task.new("OPS", "some desc", 15)
    task3 = Task.new("COMM", "some desc", 25)
    {month_id, day_id} = {1, 2}
    report = Report.add_task(report, month_id, day_id, task1)
    report = Report.add_task(report, 1, 2, task2)
    report = Report.add_task(report, 2, 3, task3)

    updated_day2 = %Day{id: 2, description: "2 tue", tasks: [task1, task2]}
    updated_day3 = %Day{id: 3, description: "3 wed", tasks: [task3]}

    assert report == %Report{
             months: [
               %Month{id: 1, description: "Jan", days: [day1, updated_day2]},
               %Month{id: 2, description: "Feb", days: [updated_day3, day4]}
             ]
           }
  end
end
