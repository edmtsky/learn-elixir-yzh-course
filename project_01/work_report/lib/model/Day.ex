defmodule WorkReport.Model.Day do
  alias WorkReport.Model.Task

  @type day_of_week() ::
          :monday | :tuesday | :wednesday | :thursday | :friday | :saturday | :sunday
  @type t() :: %__MODULE__{
          num: integer(),
          day_of_week: day_of_week(),
          tasks: [t()]
        }

  @enforce_keys [:num, :day_of_week, :tasks]
  defstruct [:num, :day_of_week, :tasks]

  @doc """
  Create a Entity of the Day model
  """
  @spec create(integer(), day_of_week(), [Task.t()]) :: t()
  def create(num, day_of_week, tasks) do
    %__MODULE__{
      num: num,
      day_of_week: day_of_week,
      tasks: tasks
    }
  end

  @spec add_taks(t(), Task.t()) :: t()
  def add_taks(self, task) do
    case Map.fetch(self, :tasks) do
      {:ok, tasks} ->
        Map.put(self, :tasks, [task | tasks])

      _ ->
        # ignore errors
        Map.put(self, :tasks, [task])
    end
  end

  @spec fetch_day([Day.t()], integer()) :: Day.t()
  def fetch_day(days, day_num) do
    case Enum.find(days, fn day -> day.num == day_num end) do
      nil -> {:error, :day_not_found}
      day -> {:ok, day}
    end
  end

  @doc """
  Calculate the total time in all tasks of this day in minutes
  """
  @spec calculate_day_total(Day.t()) :: integer()
  def calculate_day_total(day) do
    Enum.reduce(day.tasks, 0, fn %Task{time: time}, sum ->
      sum + time
    end)
  end
end
