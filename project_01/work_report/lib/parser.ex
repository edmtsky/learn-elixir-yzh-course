defmodule WorkReport.Parser do
  alias WorkReport.Model.Month
  alias WorkReport.Model.Day
  alias WorkReport.Model.Task

  @doc """
  Parses a text represendation of the markdown document into domain entities in
  the form of a set of months with days and tasks
  """
  @spec parse_file(String.t()) :: {integer(), [Month.t()]}
  def parse_file(filename) do
    # lnum, months
    init_state = {0, []}

    File.stream!(filename)
    |> Enum.reduce(init_state, fn line, state ->
      {lnum, months} = state

      case line do
        "# " <> rest ->
          {lnum + 1, add_month(rest, months)}

        "##" <> rest ->
          {lnum + 1, add_day(rest, months)}

        "[" <> _rest ->
          {lnum + 1, add_task(line, months)}

        _ ->
          {lnum + 1, months}
      end
    end)
  end

  @doc """
  adds a new month to a list of months from the processed markdown document
  """
  @spec add_month(String.t(), [Month.t()]) :: [Month.t()]
  def add_month(s, months) do
    case parse_month_name(s) do
      {:ok, month_name} ->
        [Month.create(month_name, []) | months]

      {:error, :invalid_month} ->
        months
    end
  end

  @doc """
  str "3 mon" -> to Day Struct and put to current month
  """
  @spec add_day(String.t(), [Month.t()]) :: [Month.t()]
  def add_day(str, months) do
    case parse_day_def_line(str) do
      {:ok, day} ->
        [curr_month | rest_months] = months
        [Month.add_day(curr_month, day) | rest_months]

      # ignore errors
      _ ->
        months
    end
  end

  @doc """
  str `[COMM] desc - 1m` -> to Task Struct and put to the day in a current month
  """
  @spec add_task(String.t(), [Month.t()]) :: [Month.t()]
  def add_task(str, months) do
    case parse_task(str) do
      {:ok, task} ->
        [curr_month | rest_months] = months
        [Month.add_task_to_curr_day(curr_month, task) | rest_months]

      # ignore errors
      _ ->
        months
    end
  end

  @doc """
  Parison the beginning of a new day into an empty entity for subsequent filling
  """
  @spec parse_day_def_line(String.t()) :: {:ok, Day.t()} | {:error, any()}
  def parse_day_def_line(str) do
    case Regex.run(~r/^\s*(\d+)\s+(.+?)\s*$\n?/, str) do
      [_, num_s, day_of_week_s] ->
        case parse_day_of_week_name(day_of_week_s) do
          {:ok, day_of_week} ->
            num = String.to_integer(num_s)
            {:ok, Day.create(num, day_of_week, [])}

          error ->
            error
        end

      _ ->
        {:error, :no_match_day}
    end
  end

  def parse_day_of_week_name(s) do
    case String.downcase(s) do
      "monday" -> {:ok, :monday}
      "tuesday" -> {:ok, :tuesday}
      "wednesday" -> {:ok, :wednesday}
      "thursday" -> {:ok, :thursday}
      "friday" -> {:ok, :friday}
      "saturday" -> {:ok, :saturday}
      "sunday" -> {:ok, :sunday}
      # short
      "mon" -> {:ok, :monday}
      "tue" -> {:ok, :tuesday}
      "wed" -> {:ok, :wednesday}
      "thu" -> {:ok, :thursday}
      "fri" -> {:ok, :friday}
      "sat" -> {:ok, :saturday}
      "sun" -> {:ok, :sunday}
      _ -> {:error, :invalid_day_of_weel}
    end
  end

  def parse_month_name(str) do
    # remove a "\n"(newline) from the eol
    String.trim(str)
    |> String.downcase()
    |> case do
      "january" -> {:ok, :january}
      "february" -> {:ok, :february}
      "march" -> {:ok, :march}
      "april" -> {:ok, :april}
      "may" -> {:ok, :may}
      "june" -> {:ok, :june}
      "july" -> {:ok, :july}
      "august" -> {:ok, :august}
      "september" -> {:ok, :september}
      "october" -> {:ok, :october}
      "november" -> {:ok, :november}
      "december" -> {:ok, :december}
      _ -> {:error, :invalid_month}
    end
  end

  @doc """
  `[COMM] Daily Meeting - 22m`
  """
  def parse_task(str) do
    with {category_s, desc, time_s} <- parse_task0(str),
         {:ok, category} <- parse_category(category_s),
         spent_time <- parse_time(time_s) do
      {:ok, Task.create(category, desc, spent_time)}
    end
  end

  def parse_task0(str) do
    case Regex.run(~r/^\[(\w+)\]\s(.+?) - ([^-]+)$/, str) do
      [_, category_s, desc, time_s] ->
        {category_s, desc, time_s}

      _ ->
        {:error, :no_match}
    end
  end

  @spec parse_category(String.t()) :: {:ok, Task.category()} | {:error, :invalid_category}
  def parse_category("COMM"), do: {:ok, :comm}
  def parse_category("DEV"), do: {:ok, :dev}
  def parse_category("OPS"), do: {:ok, :ops}
  def parse_category("DOC"), do: {:ok, :doc}
  def parse_category("WS"), do: {:ok, :ws}
  def parse_category("EDU"), do: {:ok, :edu}
  def parse_category(_), do: {:error, :invalid_category}

  @doc """
  Accepts the line with a description of time issues a number in minutes

  ## Example

    iex> P.parse_time("1m 2m 3h")
    183
  """
  @spec parse_time(String.t()) :: integer()
  def parse_time(time_str) do
    time_str
    |> String.trim()
    |> String.split(" ")
    |> Enum.reduce(0, fn time_unit_str, sum ->
      case String.split(time_unit_str, ~r/(?<=\d)(?=\D)/) do
        [num_str, "m"] ->
          sum + String.to_integer(num_str)

        [num_str, "h"] ->
          sum + String.to_integer(num_str) * 60

        _ ->
          0
      end
    end)
  end
end
