defmodule WorkReport.Parser do
  alias WorkReport.Model
  alias WorkReport.Model.{Report, Month, Day, Task}

  @spec parse_time(String.t()) :: integer()
  def parse_time(time_str) do
    time_str
    |> String.split(" ")
    |> Enum.map(&parse_time_item/1)
    |> Enum.sum()
  end

  def parse_time_item(item) do
    case Integer.parse(item) do
      {n, "h"} -> n * 60
      {n, "m"} -> n
      _ -> 0
    end
  end

  @spec parse_task(String.t()) :: {:ok, Task.t()} | {:error, any()}
  def parse_task(str) do
    [first_word, rest] = String.split(str, " ", parts: 2)
    category = first_word |> String.trim("[") |> String.trim("]")

    with true <- category in Model.categories(),
         [desc, time_str] <- String.split(rest, " - ") do
      time = parse_time(time_str)
      {:ok, Task.new(category, desc, time)}
    else
      false -> {:error, :invalid_category}
      _ -> {:error, :invalid_task}
    end
  end

  # temporarily for manual testing in the console - remove after implementation
  def get_report2() do
    {:ok, content} = File.read("test/sample/report-2.md")
    content
  end

  @spec parse(String.t()) :: Model.Report.t()
  def parse(content) do
    content
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.filter(fn line -> line != "" end)
    |> Enum.reduce(
      {Model.Report.new(), nil, nil},
      fn
        "# " <> line, acc -> add_month(line, acc)
        "##" <> line, acc -> add_day(line, acc)
        line, acc -> add_task(line, acc)
      end
    )
  end

  def add_month(line, {report, _curr_month_id, _curr_day_id}) do
    # todo not only a happy path
    {:ok, month_id} = Month.get_month_id(line)
    month = Month.new(month_id, line)
    report = Report.add_month(report, month)
    {report, month_id, nil}
  end

  def add_day(line, {report, curr_month_id, _curr_day_id} = _acc) do
    {day_id, desc} = Integer.parse(String.trim(line))
    description = String.trim(desc)
    day = Day.new(day_id, desc)
    updated_report = Report.add_day(report, curr_month_id, day)
    {updated_report, curr_month_id, day_id}
  end

  def add_task(line, {report, curr_month_id, curr_day_id}) do
    # todo not only a happy path
    {:ok, task} = parse_task(line)

    updated_report = Report.add_task(report, curr_month_id, curr_day_id, task)
    {updated_report, curr_month_id, curr_day_id}
  end
end
