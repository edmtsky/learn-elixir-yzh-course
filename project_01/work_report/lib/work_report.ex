defmodule WorkReport do
  @moduledoc """
  # Analyze report file and gather work statistics
  """
  alias WorkReport.Parser
  alias WorkReport.Formatter
  alias WorkReport.Analizer

  @name "Work Report"
  @version "1.0.0"

  @spec main([String.t()]) :: :ok
  def main(args) do
    case OptionParser.parse(args, options()) do
      {[help: true], [], []} -> help()
      {[version: true], [], []} -> version()
      {params, [file], []} -> do_report(Map.new(params), file)
      _ -> help()
    end
  end

  def options do
    [
      strict: [day: :integer, month: :integer, version: :boolean, help: :boolean],
      aliases: [d: :day, m: :month, v: :version, h: :help]
    ]
  end

  def do_report(params, filename) do
    month_num = Map.get(params, :month, :erlang.date() |> elem(1))
    day_num = Map.get(params, :day, :erlang.date() |> elem(2))

    ret =
      with {_lines_processed, months} <- Parser.parse_file(filename),
           {:ok, report} <- Analizer.build_report(months, month_num, day_num) do
        Formatter.format_report(report)
        |> IO.puts()
      end

    case ret do
      :ok ->
        :ok

      {:error, :month_not_found} ->
        IO.puts("month #{month_num} not found")
        # exit({:shutdown, 1})

      {:error, :day_not_found} ->
        IO.puts("day #{day_num} not found")
    end
  end

  def help() do
    IO.puts("""
    USAGE:
        work_report [OPTIONS] <path/to/report.md>
    OPTIONS:
        -m, --month <M>  Show report for month (int), current month by default
        -d, --day <D>    Show report for day (int), current day by default
        -v, --version    Show version
        -h, --help       Show this help message
    """)
  end

  def version() do
    IO.puts(@name <> " v" <> @version)
  end
end
