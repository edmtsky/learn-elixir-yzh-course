defmodule WorkReport.Model.DayTest do
  use ExUnit.Case
  alias WorkReport.Model.Day, as: D
  alias WorkReport.Model.Task
  alias TestData, as: TD

  test "create" do
    assert D.create(1, :monday, []) == %WorkReport.Model.Day{
             num: 1,
             day_of_week: :monday,
             tasks: []
           }
  end

  test "add_taks" do
    day = %WorkReport.Model.Day{num: 1, day_of_week: :monday, tasks: []}
    task = Task.create(:dev, "desc", 888)

    assert D.add_taks(day, task) == %WorkReport.Model.Day{
             num: 1,
             day_of_week: :monday,
             tasks: [
               %WorkReport.Model.Task{
                 category: :dev,
                 description: "desc",
                 time: 888
               }
             ]
           }
  end

  test "fetch_day" do
    days = [D.create(1, :monday, []), D.create(2, :tuesday, [])]

    assert D.fetch_day(days, 2) ==
             {:ok, %WorkReport.Model.Day{num: 2, day_of_week: :tuesday, tasks: []}}
  end

  test "calculate_day_total" do
    day = TD.valid_day_3monday_8tasks()
    assert D.calculate_day_total(day) == 250
  end
end
