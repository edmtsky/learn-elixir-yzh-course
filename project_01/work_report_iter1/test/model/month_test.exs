# 13-04-2025 @author Edmtsky
defmodule WorkReport.Model.MonthTest do
  use ExUnit.Case
  alias WorkReport.Model.Month, as: M
  alias WorkReport.Model.Day

  test "create" do
    assert M.create(:may, []) == %WorkReport.Model.Month{name: :may, days: []}
  end

  test "add_day" do
    month = %WorkReport.Model.Month{name: :may, days: []}
    day = Day.create(1, :mondey, [])

    assert M.add_day(month, day) == %WorkReport.Model.Month{
             name: :may,
             days: [
               %WorkReport.Model.Day{num: 1, day_of_week: :mondey, tasks: []}
             ]
           }
  end

  test "name_to_num" do
    assert M.name_to_num(:wrong) == {:error, :invalid_month_name}
    assert M.name_to_num(:january) == {:ok, 1}
    assert M.name_to_num(:december) == {:ok, 12}
  end

  test "num_to_name" do
    assert M.num_to_name(-1) == {:error, :invalid_month_number}
    assert M.num_to_name(1) == {:ok, :january}
    assert M.num_to_name(12) == {:ok, :december}
  end

  test "fetch_month success" do
    months = [M.create(:may, []), M.create(:april, [])]

    assert M.fetch_month(months, 4) ==
             {:ok, %WorkReport.Model.Month{name: :april, days: []}}
  end

  test "fetch_month fail - no month" do
    months = [M.create(:may, []), M.create(:april, [])]
    assert M.fetch_month(months, 1) == {:error, :month_not_found}
  end
end
