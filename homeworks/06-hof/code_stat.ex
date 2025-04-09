defmodule CodeStat do
  @moduledoc """
  Functions for calculating the statistics of the files in the specified
  directory. For each known type of files, it calculates the number of files in
  the directory, the number of lines(LOC) of the source code and the total size
  in bytes (per filetype)

  See the `analyze/1` function to calculate stats in the specified directory,
  and function `analyze_file/1` to calculate for one specified file.
  """

  @types [
    {"Elixir", [".ex", ".exs"]},
    {"Erlang", [".erl"]},
    {"Python", [".py"]},
    {"JavaScript", [".js"]},
    {"SQL", [".sql"]},
    {"JSON", [".json"]},
    {"Web", [".html", ".htm", ".css"]},
    {"Scripts", [".sh", ".lua", ".j2"]},
    {"Configs", [".yaml", ".yml", ".conf", ".args", ".env"]},
    {"Docs", [".md"]}
  ]

  @ignore_names [".git", ".gitignore", ".idea", "_build", "deps", "log", ".formatter.exs"]

  @ignore_extensions [".beam", ".lock", ".iml", ".log", ".pyc"]

  @max_depth 5

  @doc """
  Returns Map of source code statistics
  Recursively passes throughout the files of a given directory, calculating the
  size and number of lines in the files of different types of programming languages.

  Directory bypass depth is limited by `@max_depth` constant.

  ## Examples

      iex> CodeStat.analyze("~/code/")
      %{
        "Elixir" => %{files: 2, lines: 7, size: 58},
        "Erlang" => %{files: 1, lines: 3, size: 41},
        "Python" => %{files: 1, lines: 2, size: 13},
        "JavaScript" => %{files: 1, lines: 3, size: 32},
        "SQL" => %{files: 1, lines: 1, size: 3},
        "JSON" => %{files: 0, lines: 0, size: 0},
        "Web" => %{files: 0, lines: 0, size: 0},
        "Scripts" => %{files: 0, lines: 0, size: 0},
        "Configs" => %{files: 1, lines: 1, size: 11},
        "Docs" => %{files: 2, lines: 4, size: 32},
        "Other" => %{files: 2, lines: 2, size: 34}
      }
  """
  def analyze(path) do
    do_analyze_dir(path, 0, mk_initial_result_map())
  end

  @doc """
  Counts statistics on one specific file (not a directory)
  return a map with collected stats

  ## Examples

      iex> CodeStat.do_analyze_file("code_stat.ex", %{})
      %{"Elixir" => %{files: 1, lines: 128, size: 3723}}
  """
  def analyze_file(path) do
    map = %{get_filetype_name(Path.extname(path)) => mk_ft_stat_entry()}
    do_analyze_file(path, map)
  end

  defp mk_ft_stat_entry() do
    %{files: 0, lines: 0, size: 0}
  end

  defp mk_initial_result_map() do
    initial_map = %{"Other" => mk_ft_stat_entry()}

    @types
    |> Enum.reduce(initial_map, fn {ft, _exts}, map ->
      Map.put(map, ft, mk_ft_stat_entry())
    end)
  end

  defp do_analyze_dir(_dirpath, depth, result_map) when depth > @max_depth do
    result_map
  end

  defp do_analyze_dir(dirpath, depth, result_map) when depth <= @max_depth do
    files =
      dirpath
      |> File.ls!()
      |> Enum.filter(fn name -> !Enum.member?(@ignore_names, name) end)
      |> Enum.filter(fn name -> !Enum.member?(@ignore_extensions, Path.extname(name)) end)

    files
    |> Enum.reduce(result_map, fn filename, acc_map ->
      abs_path = Path.join(dirpath, filename)
      # IO.puts("Process: " <> abs_path)
      # IO.inspect(acc_map)

      new_acc_map =
        if File.dir?(abs_path) do
          do_analyze_dir(abs_path, depth + 1, acc_map)
        else
          do_analyze_file(abs_path, acc_map)
        end

      new_acc_map
      # |> IO.inspect()
    end)
  end


  defp do_analyze_file(path, acc_map) do
    filetype_name =
      Path.extname(path)
      |> get_filetype_name()

    # process file to get the LinesOfCode and Size in bytes
    {lines_cnt, file_size} =
      File.stream!(path)
      |> Enum.reduce({0, 0}, fn line, {cnt, size} ->
        {cnt + 1, size + String.length(line)}
      end)

    # statistic for a specified filetype_name
    ft_stat = Map.get(acc_map, filetype_name) #, %{files: 0, lines: 0, size: 0})

    vfiles = Map.get(ft_stat, :files, 0)
    vlines = Map.get(ft_stat, :lines, 0)
    vsize = Map.get(ft_stat, :size, 0)

    Map.put(acc_map, filetype_name, %{
      files: vfiles + 1,
      lines: vlines + lines_cnt,
      size: vsize + file_size
    })
  end

  @doc """
  Returns readbale type of source file by given extension

  ## Examples
      iex> CodeStat.get_filetype_name(".ex")
      "Elixir"

      iex> CodeStat.get_filetype_name("")
      "Other"
  """
  def get_filetype_name(ext) do
    ft =
      Enum.find_value(@types, fn {name, exts} -> ext in exts && name end)

    if ft, do: ft, else: "Other"
  end
end
