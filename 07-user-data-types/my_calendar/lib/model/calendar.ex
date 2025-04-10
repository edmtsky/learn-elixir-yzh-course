defmodule MyCalendar.Model do
  alias MyCalendar.Model.CalendarItem

  defmodule Calendar do
    @type t() :: %__MODULE__{
            items: [CalendarItem.t()]
          }
    @enforce_keys [:items]
    defstruct [:items]

    @spec add_item(Calendar.t(), CalendarItem.t()) :: Calendar.t()
    def add_item(calendar, item) do
      items = [item | calendar.items]
      %Calendar{calendar | items: items}
    end

    @spec show(Calendar.t()) :: String.t()
    def show(calendar) do
      Enum.map(
        calendar.items,
        fn item ->
          title = CalendarItem.get_title(item)
          time = CalendarItem.get_time(item) |> DateTime.to_iso8601()
          "#{title} at #{time}"
        end
      )
      |> Enum.join("\n")
    end
  end

  defprotocol CalendarItem do
    @spec get_title(CalendarItem.t()) :: String.t()
    def get_title(event)

    @spec get_time(CalendarItem.t()) :: DateTime.t()
    def get_time(event)
  end

  defimpl CalendarItem, for: Map do
    @spec get_title(CalendarItem.t()) :: String.t()
    def get_title(event), do: Map.get(event, :title, "Unknow")

    @spec get_time(CalendarItem.t()) :: DateTime.t()
    def get_time(event), do: Map.get(event, :time)
  end

  # for the MyCalendar.Model.EventStruct.Event see inside it
  # for the MyCalendar.Model.EventTypedStruct.Event see inside it

  defimpl CalendarItem, for: Tuple do
    @spec get_title(CalendarItem.t()) :: String.t()
    def get_title({:event, title, _, _, _, _}), do: title

    @spec get_time(CalendarItem.t()) :: DateTime.t()
    def get_time({:event, _, _, time, _, _}), do: time
  end
end
