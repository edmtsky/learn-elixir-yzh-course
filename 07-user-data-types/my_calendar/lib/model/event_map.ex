defmodule MyCalendar.Model.EventMap do

  defmodule Place do
    def new(office, room) do
      %{
        office: office,
        room: room
      }
    end
  end

  # datatime

  defmodule Participant do
    def new(name, role) do
      %{
        name: name,
        role: role
      }
    end
  end

  defmodule Topic do
    def new(title, description) do
      %{
        title: title,
        description: description
      }
    end
  end

  defmodule Event do
    def new(title, place, time, participants, agenda) do
      %{
        title: title,
        place: place,
        time: time,
        participants: participants,
        agenda: agenda
      }
    end

    def add_participant(event, new_participant) do
      Map.update(event, :participants, [], fn participants ->
        [new_participant | participants]
      end)
    end
  end
end
