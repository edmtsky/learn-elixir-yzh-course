defmodule ParserTest do
  use ExUnit.Case

  alias WorkReport.Parser, as: P
  alias WorkReport.Model.{Report, Month, Day, Task}

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

  test "parse task" do
    str = "[DEV] some desc - 42m"
    task = %Task{category: "DEV", description: "some desc", time: 42}

    assert {:ok, task} == P.parse_task(str)
  end

  test "parse invalid task" do
    str1 = "[SOME] some desc - 42m"
    assert {:error, :invalid_category} == P.parse_task(str1)

    str2 = "[OPS] some - desc - 2m"
    assert {:error, :invalid_task} == P.parse_task(str2)
  end

  test "add_day" do
    month = Month.new(1, "January")
    report = Report.new() |> Report.add_month(month)
    line = "16 tue"
    acc = {report, 1, nil, []}

    assert P.add_day(1, line, acc) ==
             {%Report{
                months: [
                  %Month{
                    id: 1,
                    description: "January",
                    days: [%Day{id: 16, description: " tue", tasks: []}]
                  }
                ]
              }, 1, 16, []}
  end

  test "parse, happy path" do
    {:ok, report} = File.read("test/sample/report-4.md")

    assert P.parse(report) ==
             {%WorkReport.Model.Report{
                months: [
                  %WorkReport.Model.Month{
                    id: 3,
                    description: "March",
                    days: [
                      %WorkReport.Model.Day{
                        id: 9,
                        description: " tue",
                        tasks: [
                          %WorkReport.Model.Task{
                            category: "DEV",
                            description: "TASK-15 implement feature",
                            time: 42
                          },
                          %WorkReport.Model.Task{
                            category: "COMM",
                            description: "Daily Meeting",
                            time: 24
                          }
                        ]
                      },
                      %WorkReport.Model.Day{
                        id: 10,
                        description: " wed",
                        tasks: [
                          %WorkReport.Model.Task{
                            category: "DEV",
                            description: "Review Pull Requests",
                            time: 17
                          },
                          %WorkReport.Model.Task{
                            category: "COMM",
                            description: "Sprint Planning",
                            time: 60
                          }
                        ]
                      }
                    ]
                  },
                  %WorkReport.Model.Month{
                    id: 4,
                    description: "April",
                    days: [
                      %WorkReport.Model.Day{
                        id: 15,
                        description: " thu",
                        tasks: [
                          %WorkReport.Model.Task{
                            category: "COMM",
                            description: "Daily Meeting",
                            time: 19
                          },
                          %WorkReport.Model.Task{
                            category: "DEV",
                            description: "TASK-19 make test data",
                            time: 32
                          }
                        ]
                      },
                      %WorkReport.Model.Day{
                        id: 16,
                        description: " fri",
                        tasks: [
                          %WorkReport.Model.Task{
                            category: "DEV",
                            description: "TASK-20 implementation",
                            time: 17
                          },
                          %WorkReport.Model.Task{
                            category: "DEV",
                            description: "TASK-19 investigate bug",
                            time: 43
                          },
                          %WorkReport.Model.Task{
                            category: "DEV",
                            description: "TASK-19 fix bug",
                            time: 28
                          }
                        ]
                      }
                    ]
                  }
                ]
              }, []}
  end

  test "parse, with errors invalid month" do
    {:ok, report} = File.read("test/sample/report-3.md")

    assert P.parse(report) ==
             {%WorkReport.Model.Report{
                months: [
                  %WorkReport.Model.Month{
                    id: 3,
                    description: "March",
                    days: [
                      %WorkReport.Model.Day{
                        id: 9,
                        description: " tue",
                        tasks: [
                          %WorkReport.Model.Task{
                            category: "DEV",
                            description: "TASK-15 implement feature",
                            time: 42
                          },
                          %WorkReport.Model.Task{
                            category: "COMM",
                            description: "Daily Meeting",
                            time: 24
                          },
                          %WorkReport.Model.Task{
                            category: "DEV",
                            description: "Review Pull Requests",
                            time: 17
                          },
                          %WorkReport.Model.Task{
                            category: "COMM",
                            description: "Sprint Planning",
                            time: 60
                          }
                        ]
                      },
                      %WorkReport.Model.Day{
                        id: 15,
                        description: " thu",
                        tasks: [
                          %WorkReport.Model.Task{
                            category: "COMM",
                            description: "Daily Meeting",
                            time: 19
                          },
                          %WorkReport.Model.Task{
                            category: "DEV",
                            description: "TASK-19 make test data",
                            time: 32
                          }
                        ]
                      },
                      %WorkReport.Model.Day{
                        id: 16,
                        description: " fri",
                        tasks: [
                          %WorkReport.Model.Task{
                            category: "DEV",
                            description: "TASK-20 implementation",
                            time: 17
                          }
                        ]
                      }
                    ]
                  }
                ]
              },
              [
                {7, "invalid day @@10 wed"},
                {12, "invalid month April@@"},
                {20, "invalid category [DEV@@] TASK-19 investigate bug - 43m"},
                {21, "invalid task [DEV] TASK-19 fix - bug - 28m"}
              ]}
  end
end
