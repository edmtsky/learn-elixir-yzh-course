defmodule ParserTest do
  use ExUnit.Case

  alias WorkReport.Parser, as: P

  test "parse time" do
    assert P.parse_time("1m") == 1
    assert P.parse_time("5m") == 5
    assert P.parse_time("12m") == 12
    assert P.parse_time("42m") == 42
    assert P.parse_time("59m") == 59
    assert P.parse_time("60m") == 60
    assert P.parse_time("61m") == 61
    assert P.parse_time("1h") == 60
    assert P.parse_time("1h 5m") == 65
    assert P.parse_time("1h 30m") == 90
    assert P.parse_time("2h 20m") == 140
    assert P.parse_time("1h 90m") == 150
    assert P.parse_time("3h") == 180
    assert P.parse_time("10h") == 600
    assert P.parse_time("10h 15m") == 615

    assert P.parse_time("") == 0
    assert P.parse_time("0m") == 0
    assert P.parse_time("0h") == 0
    assert P.parse_time("0m 0h") == 0
    assert P.parse_time("whatever") == 0
  end

  test "parse_month_name" do
    assert P.parse_month_name("january") == {:ok, :january}
    assert P.parse_month_name("January") == {:ok, :january}
    assert P.parse_month_name("JANUARY") == {:ok, :january}
    assert P.parse_month_name("JA") == {:error, :invalid_month}
    assert P.parse_month_name("February") == {:ok, :february}

    assert P.parse_month_name("March") == {:ok, :march}
    assert P.parse_month_name("April") == {:ok, :april}
    assert P.parse_month_name("May") == {:ok, :may}
    assert P.parse_month_name("June") == {:ok, :june}
    assert P.parse_month_name("July") == {:ok, :july}
    assert P.parse_month_name("August") == {:ok, :august}
    assert P.parse_month_name("September") == {:ok, :september}
    assert P.parse_month_name("October") == {:ok, :october}
    assert P.parse_month_name("November") == {:ok, :november}
    assert P.parse_month_name("December") == {:ok, :december}
    assert P.parse_month_name("December\n") == {:ok, :december}
    assert P.parse_month_name(" December \n") == {:ok, :december}
  end

  test "parse_day_name" do
    assert P.parse_day_of_week_name("monday") == {:ok, :monday}
    assert P.parse_day_of_week_name("mon") == {:ok, :monday}
  end

  test "parse_day_def_line" do
    assert P.parse_day_def_line(" 5 wed") ==
             {:ok,
              %WorkReport.Model.Day{
                num: 5,
                day_of_week: :wednesday,
                tasks: []
              }}
  end

  test "parse task raw" do
    assert P.parse_task0("[DEV] desc 1h 0m") == {:error, :no_match}
    assert P.parse_task0("[DEV] desc - 1h 0m") == {"DEV", "desc", "1h 0m"}
    assert P.parse_task0("[DEV] ab ce - 1h 0m") == {"DEV", "ab ce", "1h 0m"}
    assert P.parse_task0("[DEV] ab - ce - 1h 0m") == {"DEV", "ab - ce", "1h 0m"}
    assert P.parse_task0("[DEV] ab - ce - 1h") == {"DEV", "ab - ce", "1h"}
  end

  test "parse_task" do
    assert P.parse_task("[DEV] ab - ce - 1h") ==
             {:ok,
              %WorkReport.Model.Task{
                category: :dev,
                description: "ab - ce",
                time: 60
              }}
  end

  # Stream parser

  test "add_month" do
    assert P.add_month("April", []) == [
             %WorkReport.Model.Month{name: :april, days: []}
           ]
  end

  test "add_day" do
    months = [%WorkReport.Model.Month{name: :april, days: []}]

    assert P.add_day("3 monday", months) == [
             %WorkReport.Model.Month{
               name: :april,
               days: [
                 %WorkReport.Model.Day{
                   num: 3,
                   day_of_week: :monday,
                   tasks: []
                 }
               ]
             }
           ]
  end

  test "add_task to an empty day" do
    months = [
      %WorkReport.Model.Month{
        name: :april,
        days: [%WorkReport.Model.Day{num: 3, day_of_week: :monday, tasks: []}]
      }
    ]

    assert P.add_task("[DEV] Review Pull Requests - 27m", months) == [
             %WorkReport.Model.Month{
               name: :april,
               days: [
                 %WorkReport.Model.Day{
                   num: 3,
                   day_of_week: :monday,
                   tasks: [
                     %WorkReport.Model.Task{
                       category: :dev,
                       description: "Review Pull Requests",
                       time: 27
                     }
                   ]
                 }
               ]
             }
           ]
  end

  test "add_task to non empty day" do
    months = [
      %WorkReport.Model.Month{
        name: :april,
        days: [
          %WorkReport.Model.Day{
            num: 3,
            day_of_week: :monday,
            tasks: [
              %WorkReport.Model.Task{
                category: :dev,
                description: "Review Pull Requests",
                time: 27
              }
            ]
          }
        ]
      }
    ]

    assert P.add_task("[COMM] Daily Meeting - 15m", months) == [
             %WorkReport.Model.Month{
               name: :april,
               days: [
                 %WorkReport.Model.Day{
                   num: 3,
                   day_of_week: :monday,
                   tasks: [
                     %WorkReport.Model.Task{
                       category: :comm,
                       description: "Daily Meeting",
                       time: 15
                     },
                     %WorkReport.Model.Task{
                       category: :dev,
                       description: "Review Pull Requests",
                       time: 27
                     }
                   ]
                 }
               ]
             }
           ]
  end
end
