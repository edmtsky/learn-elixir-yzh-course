defmodule WorkReport.Model do
  @doc """
  Returns a list of all valid categories
  """
  def categories() do
    ["COMM", "DEV", "OPS", "DOC", "WS", "EDU"]
  end

  defmodule Task do
    @type t :: %__MODULE__{
            category: String.t(),
            description: String.t(),
            time: non_neg_integer()
          }

    @enforce_keys [:category, :description, :time]
    defstruct [:category, :description, :time]

    @spec new(String.t(), String.t(), integer()) :: t()
    def new(category, description, time) do
      %__MODULE__{
        category: category,
        description: description,
        time: time
      }
    end
  end

  defmodule Day do
    @type t :: %__MODULE__{
            id: integer(),
            description: String.t(),
            tasks: [Task.t()]
          }

    @enforce_keys [:id]
    defstruct [:id, :description, :tasks]

    @spec new(integer(), String.t(), Task.t()) :: t()
    def new(id, description \\ "", tasks \\ []) do
      %__MODULE__{
        id: id,
        description: description,
        tasks: tasks
      }
    end

    @spec add_task(t(), Task.t()) :: t()
    def add_task(day, task) do
      # %__MODULE__{day | tasks: [task | day.tasks]}
      %__MODULE__{day | tasks: day.tasks ++ [task]}
    end
  end

  defmodule Month do
    @type t :: %__MODULE__{
            id: integer(),
            description: String.t(),
            days: [Day.t()]
          }

    @enforce_keys [:id]
    defstruct [:id, :description, :days]

    @spec new(integer(), String.t(), Day.t()) :: t()
    def new(id, description \\ "", days \\ []) do
      %__MODULE__{
        id: id,
        description: description,
        days: days
      }
    end

    @spec add_day(t(), Day.t()) :: t()
    def add_day(month, day) do
      %__MODULE__{month | days: month.days ++ [day]}
    end

    @spec add_task(t(), integer(), Task.t()) :: t()
    def add_task(month, day_id, task) do
      days =
        Enum.map(month.days, fn day ->
          if day.id == day_id do
            Day.add_task(day, task)
          else
            day
          end
        end)

      %__MODULE__{month | days: days}
    end

    @doc """
    Map month_id to name
    """
    @spec months() :: map()
    def months() do
      %{
        1 => "January",
        2 => "February",
        3 => "March",
        4 => "April",
        5 => "May",
        6 => "June",
        7 => "July",
        8 => "August",
        9 => "September",
        10 => "October",
        11 => "November",
        12 => "December"
      }
    end

    @spec get_month_id(String.t()) :: {:ok, integer()} | :error
    def get_month_id(month_name) do
      month_ids =
        Enum.reduce(months(), %{}, fn {k, v}, acc ->
          Map.put(acc, v, k)
        end)

      Map.fetch(month_ids, String.capitalize(month_name))
    end
  end

  defmodule Report do
    @type t :: %__MODULE__{
            months: [Month.t()]
          }

    @enforce_keys [:months]
    defstruct [:months]

    @spec new([Month.t()]) :: t()
    def new(months \\ []) do
      %__MODULE__{
        months: months
      }
    end

    @spec add_month(t(), Month.t()) :: t()
    def add_month(report, month) do
      %__MODULE__{report | months: report.months ++ [month]}
    end

    @spec add_day(t(), integer(), Day.t()) :: t()
    def add_day(report, month_id, day) do
      months =
        Enum.map(
          report.months,
          fn month ->
            if month.id == month_id do
              Month.add_day(month, day)
            else
              month
            end
          end
        )

      %__MODULE__{report | months: months}
    end

    @spec add_task(t(), integer(), integer(), Task.t()) :: t()
    def add_task(report, month_id, day_id, task) do
      months =
        Enum.map(
          report.months,
          fn month ->
            if month.id == month_id do
              Month.add_task(month, day_id, task)
            else
              month
            end
          end
        )

      %__MODULE__{report | months: months}
    end
  end
end
