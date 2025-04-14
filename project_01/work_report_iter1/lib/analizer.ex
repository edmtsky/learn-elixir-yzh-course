defmodule WorkReport.Analizer do
  alias WorkReport.Model.Report
  alias WorkReport.Model.Report.MonthTotals
  alias WorkReport.Model.Month
  alias WorkReport.Model.Day
  alias WorkReport.Model.Task

  @spec build_report([Month.t()], integer(), integer()) :: Report.t()
  def build_report(months, month_num, day_num) do
    with {:ok, month} <- Month.fetch_month(months, month_num),
         {:ok, day} <- Day.fetch_day(month.days, day_num),
         day_totals = Day.calculate_day_total(day),
         {:ok, month_totals} = calculate_month_totals(month) do
      {:ok, Report.create(day, month.name, day_totals, month_totals)}
    end
  end

  @doc """
  """
  @spec calculate_month_totals(Month.t()) :: integer()
  def calculate_month_totals(month) do
    # categories_spent_time_per_month_map
    time_per_month_map =
      process_month_times(month, Task.new_categories_map())

    # days_count()
    days = Enum.count(month.days)
    total_min = calculate_total_time(time_per_month_map)
    avg = div(total_min, days)

    {:ok, MonthTotals.create(time_per_month_map, total_min, days, avg)}
  end

  @doc """
  %{comm: 0, dev: 0, ...}
  """
  @spec process_month_times([Month.t()]) :: map()
  def process_month_times(month, categories_map) do
    # item, state
    %Month{name: _name, days: days} = month
    Enum.reduce(days, categories_map, &process_day_times/2)
  end

  def process_month_times(month) do
    process_month_times(month, Task.new_categories_map())
  end

  @spec process_day_times(Day.t(), map()) :: map()
  def process_day_times(day, categories_map) do
    %Day{num: _num, day_of_week: _day_of_week, tasks: tasks} = day
    #           coll   init_state      reducer
    Enum.reduce(tasks, categories_map, &process_task_time/2)
  end

  @doc """
  update a specific category spent time of the category in a task in the given map
  """
  @spec process_task_time(Task.t(), map()) :: map()
  def process_task_time(task, categories_map) do
    %Task{category: category, description: _desc, time: time} = task
    oldtime = Map.get(categories_map, category, 0)
    Map.put(categories_map, category, oldtime + time)
  end

  @doc """
  get the amount of the total time in minutes of all categories
  """
  @spec calculate_total_time(map()) :: integer()
  def calculate_total_time(categories_map) do
    categories_map |> Map.values() |> Enum.sum()
  end
end
