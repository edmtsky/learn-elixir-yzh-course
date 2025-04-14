defmodule WorkReport.Model.Month do
  alias WorkReport.Model.Day

  @months [
    :january,
    :february,
    :march,
    :april,
    :may,
    :june,
    :july,
    :august,
    :september,
    :october,
    :november,
    :december
  ]

  @type months_enum() ::
          :january
          | :february
          | :march
          | :april
          | :may
          | :june
          | :july
          | :august
          | :september
          | :october
          | :november
          | :december
  @type t() :: %__MODULE__{
          name: months_enum(),
          days: [Day.t()]
        }

  @enforce_keys [:name, :days]
  defstruct [:name, :days]

  @doc """
  Create a Entity of the Month model
  """
  @spec create(months_enum(), [Day.t()]) :: t()
  def create(month, days) do
    %__MODULE__{
      name: month,
      days: days
    }
  end

  # def month_to_number(month) when month in @months do
  #   Enum.find_index(@months, fn m -> m == month end) + 1
  # end

  @doc """
  Convert the name of the month to a number
  """
  @spec name_to_num(String.t()) :: integer()
  def name_to_num(month_name_s) do
    case Enum.find_index(@months, fn m -> m == month_name_s end) do
      nil -> {:error, :invalid_month_name}
      n -> {:ok, n + 1}
    end
  end

  @spec name_to_num(String.t()) :: integer()
  def num_to_name(month_number) when month_number in 1..12 do
    {:ok, Enum.at(@months, month_number - 1)}
  end

  def num_to_name(_month_number) do
    {:error, :invalid_month_number}
  end

  @spec add_day(t(), Day.t()) :: t()
  def add_day(self, day) do
    case Map.fetch(self, :days) do
      {:ok, days} ->
        Map.put(self, :days, [day | days])

      _ ->
        Map.put(self, :days, [day])
    end
  end

  @doc """
  Adds the task on the last day in a given month
  """
  @spec add_day(t(), Day.t()) :: t()
  def add_task_to_curr_day(self, task) do
    case Map.fetch(self, :days) do
      {:ok, days} ->
        [curr_day | rest_days] = days
        updated_curr_day = Day.add_taks(curr_day, task)
        Map.put(self, :days, [updated_curr_day | rest_days])

      _ ->
        # ignore  - without changes
        self
    end
  end

  #

  @spec fetch_month([Month.t()], integer()) :: Month.t()
  def fetch_month(months, month_num) do
    with {:ok, month_name} <- num_to_name(month_num) do
      case Enum.find(months, fn month -> month.name == month_name end) do
        nil -> {:error, :month_not_found}
        month -> {:ok, month}
      end
    end
  end

  def days_count(month) do
    Enum.count(month.days)
  end
end
