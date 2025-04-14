defmodule WorkReport.Model.Report do
  alias WorkReport.Model.Month
  alias WorkReport.Model.Day

  @type t() :: %__MODULE__{
          day: Day.t(),
          # amount of spent time in minutes
          day_totals: integer(),
          month_name: Month.month_names(),
          month_totals: MonthTotals.t()
        }

  @enforce_keys [:day, :month_name, :day_totals, :month_totals]
  defstruct [:day, :month_name, :day_totals, :month_totals]

  @spec create(Day.t(), Month.month_name(), integer(), MonthTotals.t()) :: t()
  def create(day, month_name, day_totals, month_totals) do
    %__MODULE__{
      day: day,
      month_name: month_name,
      day_totals: day_totals,
      month_totals: month_totals
    }
  end

  # about selected day and month
  defmodule MonthTotals do
    @type t() :: %__MODULE__{
            categories_time: map(),
            # in minutes
            total_time: integer(),
            days_cnt: integer(),
            avg_day_time: integer()
          }

    @enforce_keys [:categories_time, :total_time, :days_cnt, :avg_day_time]
    defstruct [:categories_time, :total_time, :days_cnt, :avg_day_time]

    def create(categories_time, total_time, days_cnt, avg_day_time) do
      %__MODULE__{
        total_time: total_time,
        days_cnt: days_cnt,
        avg_day_time: avg_day_time,
        categories_time: categories_time
      }
    end
  end
end
