# 14-04-2025 @author Edmtsky
defmodule WorkReport.AnalizerTest do
  use ExUnit.Case
  alias WorkReport.Analizer, as: A
  # alias WorkReport.Model.Report
  # alias WorkReport.Model.Month
  # alias WorkReport.Model.Day
  alias WorkReport.Model.Task
  alias TestData, as: TD

  test "process_task_time" do
    map = Task.new_categories_map()
    task = TD.valid_dev_task_pull_req_27m()

    assert A.process_task_time(task, map) ==
             %{ops: 0, dev: 27, doc: 0, edu: 0, comm: 0, ws: 0}
  end

  test "process_day_times" do
    map = Task.new_categories_map()
    day = TD.valid_day_3monday_8tasks()

    assert A.process_day_times(day, map) ==
             %{ops: 56, dev: 157, doc: 22, edu: 0, comm: 15, ws: 0}
  end

  test "process_month_times" do
    map = Task.new_categories_map()
    month = TD.valid_month_from_report_1()

    assert A.process_month_times(month, map) ==
             %{comm: 178, dev: 476, ops: 56, doc: 99, ws: 0, edu: 0}
  end

  test "calculate_total_time" do
    map = %{comm: 178, dev: 476, ops: 56, doc: 99, ws: 0, edu: 0}
    assert A.calculate_total_time(map) == 809
  end

  test "calculate_month_totals" do
    month = TD.valid_month_from_report_1()

    assert A.calculate_month_totals(month) ==
             {:ok,
              %WorkReport.Model.Report.MonthTotals{
                categories_time: %{
                  ops: 56,
                  dev: 476,
                  doc: 99,
                  comm: 178,
                  edu: 0,
                  ws: 0
                },
                total_time: 809,
                days_cnt: 3,
                avg_day_time: 269
              }}
  end

  test "build_report" do
    months = [TestData.valid_month_from_report_1()]
    valid_report_1 = TestData.valid_report_1()
    assert A.build_report(months, 5, 3) == {:ok, valid_report_1}
  end
end
