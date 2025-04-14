defmodule ParserTest do
  use ExUnit.Case

  alias WorkReport.Parser, as: P
  alias WorkReport.Model.Task

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
end
