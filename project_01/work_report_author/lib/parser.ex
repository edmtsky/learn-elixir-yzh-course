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

  def get_report3() do
    {:ok, content} = File.read("test/sample/report-3.md")
    content
  end

  @spec parse(String.t()) :: {Model.Report.t(), [Model.error_t()]}
  def parse(content) do
    lnums = Stream.iterate(1, fn n -> n + 1 end)

    content
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.zip_with(lnums, fn line, lnum -> {lnum, line} end)
    |> Enum.filter(fn {_, line} -> line != "" end)
    |> Enum.reduce(
      {Model.Report.new(), nil, nil, []},
      fn
        {lnum, "# " <> line}, acc -> add_month(lnum, line, acc)
        {lnum, "##" <> line}, acc -> add_day(lnum, line, acc)
        {lnum, line}, acc -> add_task(lnum, line, acc)
      end
    )
    |> then(fn {report, _, _, errors} -> {report, Enum.reverse(errors)} end)
  end

  def add_month(lnum, line, {report, curr_month_id, curr_day_id, errors}) do
    case Month.get_month_id(line) do
      {:ok, month_id} ->
        month = Month.new(month_id, line)
        report = Report.add_month(report, month)
        {report, month_id, nil, errors}

      :error ->
        error = {lnum, "invalid month #{line}"}
        {report, curr_month_id, curr_day_id, [error | errors]}
    end
  end

  def add_day(lnum, line, {report, curr_month_id, curr_day_id, errors} = _acc) do
    case Integer.parse(String.trim(line)) do
      {day_id, desc} ->
        description = String.trim(desc)
        day = Day.new(day_id, desc)
        updated_report = Report.add_day(report, curr_month_id, day)
        {updated_report, curr_month_id, day_id, errors}

      :error ->
        error = {lnum, "invalid day#{line}"}
        {report, curr_month_id, curr_day_id, [error | errors]}
    end
  end

  def add_task(lnum, line, {report, curr_month_id, curr_day_id, errors}) do
    case parse_task(line) do
      {:ok, task} ->
        updated_report = Report.add_task(report, curr_month_id, curr_day_id, task)
        {updated_report, curr_month_id, curr_day_id, errors}

      {:error, :invalid_category} ->
        error = {lnum, "invalid category #{line}"}
        {report, curr_month_id, curr_day_id, [error | errors]}

      {:error, :invalid_task} ->
        error = {lnum, "invalid task #{line}"}
        {report, curr_month_id, curr_day_id, [error | errors]}
    end
  end
end
