defmodule MyCalendar.Model.EventStruct do
  defmodule Place do
    @behaviour Access
    @enforce_keys [:office, :room]

    defstruct [:office, :room]

    @impl true
    def fetch(place, :office), do: {:ok, place.office}
    def fetch(place, :room), do: {:ok, place.room}
    def fetch(_place, _), do: :error

    @impl true
    def get_and_update(place, :office, f) do
      {curr_val, new_val} = f.(place.office)
      new_place = %Place{place | office: new_val}
      {curr_val, new_place}
    end

    @impl true
    def get_and_update(place, :room, f) do
      {curr_val, new_val} = f.(place.room)
      new_place = %Place{place | room: new_val}
      {curr_val, new_place}
    end

    def get_and_update(place, _, _f) do
      {nil, place}
    end

    @impl true
    def pop(place, _key) do
      place
    end
  end

  defmodule Participant do
    @enforce_keys [:name, :role]

    defstruct [:name, :role]
  end

  defmodule Topic do
    @enforce_keys [:title]

    defstruct [
      :title,
      :description,
      {:priority, :medium}
    ]
  end

  defmodule Event do
    alias MyCalendar.Model.CalendarItem

    @enforce_keys [:title, :place, :time]

    defstruct [
      :title,
      :place,
      :time,
      {:participants, []},
      {:agenda, []}
    ]

    def add_participant(
          %Event{participants: participants} = event,
          %Participant{} = participant
        ) do
      participants = [participant | participants]
      %Event{event | participants: participants}
    end

    # aka update by name
    def replace_participant(
          %Event{participants: participants} = event,
          %Participant{} = new_participant
        ) do
      participants =
        Enum.filter(participants, fn p ->
          p.name != new_participant.name
        end)

      participants = [new_participant | participants]
      %Event{event | participants: participants}
    end

    # defimpl CalendarItem, for: MyCalendar.Model.EventStruct.Event do
    defimpl CalendarItem do
      @spec get_title(CalendarItem.t()) :: String.t()
      def get_title(event), do: event.title

      @spec get_time(CalendarItem.t()) :: DateTime.t()
      def get_time(event), do: event.time
    end
  end
end
