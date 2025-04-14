defmodule WorkReport.Parser do
  alias WorkReport.Model.Task
  alias WorkReport.Model

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
end
