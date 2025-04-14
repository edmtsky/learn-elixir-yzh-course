defmodule FormatterTest do
  use ExUnit.Case

  alias WorkReport.Formatter, as: F
  alias TestData, as: TD

  test "format time" do
    assert F.format_time(0) == "0"
    assert F.format_time(1) == "1m"
    assert F.format_time(12) == "12m"
    assert F.format_time(42) == "42m"
    assert F.format_time(59) == "59m"
    assert F.format_time(60) == "1h"
    assert F.format_time(61) == "1h 1m"
    assert F.format_time(65) == "1h 5m"
    assert F.format_time(90) == "1h 30m"
    assert F.format_time(140) == "2h 20m"
    assert F.format_time(150) == "2h 30m"
    assert F.format_time(180) == "3h"
    assert F.format_time(250) == "4h 10m"
    assert F.format_time(269) == "4h 29m"
    assert F.format_time(600) == "10h"
    assert F.format_time(615) == "10h 15m"
    assert F.format_time(809) == "13h 29m"
  end

  test "format_task" do
    task = %WorkReport.Model.Task{
      category: :dev,
      description: "Review Pull Requests",
      time: 27
    }

    assert F.format_task(task) == " - DEV: Review Pull Requests - 27m"
  end

  test "format_month_totals" do
    month_totals = TD.valid_report_1_month_totals()

    assert F.format_month_totals(month_totals) ==
             "   Total: 13h 29m, Days: 3, Avg: 4h 29m"
  end

  test "format_report 1" do
    report1 = TD.valid_report_1()
    {:ok, valid_response1} = File.read("test/sample/response-1-1.md")
    assert F.format_report(report1) <> "\n" == valid_response1
  end
end
