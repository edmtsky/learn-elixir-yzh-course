defmodule MyCalendar do
  @moduledoc """
  """

  @doc """
  """
  def sample_event_tuple() do
    alias MyCalendar.Model.EventTuple, as: T

    place = T.Place.new("Office #1", "#Room 42")
    time = ~U[2025-04-09 15:00:00Z]
    participants = [
      T.Participant.new("Bob", :project_manager),
      T.Participant.new("Petya", :developer),
      T.Participant.new("Kate", :qa),
      T.Participant.new("Helen", :devops),
    ]
    agenda = [
      T.Topic.new("Inteview", "candidat for developer position"),
      T.Topic.new("Direction", "disscuss main goals"),
      T.Topic.new("Cookies", "what to buy"),
    ]

    T.Event.new("Weekly Team Meeting", place, time, participants, agenda)
  end

  @doc """
  """
  def sample_event_map() do
    alias MyCalendar.Model.EventMap, as: M

    place = M.Place.new("Office #1", "#Room 42")
    time = ~U[2025-04-09 15:00:00Z]
    participants = [
      M.Participant.new("Bob", :project_manager),
      M.Participant.new("Petya", :developer),
      M.Participant.new("Kate", :qa),
      M.Participant.new("Helen", :devops),
    ]
    agenda = [
      M.Topic.new("Inteview", "candidat for developer position"),
      M.Topic.new("Direction", "disscuss main goals"),
      M.Topic.new("Cookies", "what to buy"),
    ]

    M.Event.new("Weekly Team Meeting", place, time, participants, agenda)
  end

  def sample_event_struct() do
    alias MyCalendar.Model.EventStruct, as: S

    place = %S.Place{office: "Office #1", room: "#Room 42"}

    time = ~U[2025-04-09 17:17:00Z]
    participants = [
      %S.Participant{name: "Bob", role: :project_manager},
      %S.Participant{name: "Petya", role: :developer},
      %S.Participant{name: "Kate", role: :qa},
    ]
    agenda = [
      %S.Topic{title: "Interview", description: "candidat for developer position"},
      %S.Topic{title: "Direction", description: "disscuss main goals"},
    ]

    %S.Event{
      title: "Weekly Team Meeting",
      place: place,
      time: time,
      participants: participants,
      agenda: agenda
    }
  end

  def sample_event_typed_struct() do
    alias MyCalendar.Model.EventTypedStruct, as: TS

    place = %TS.Place{office: "Office #1", room: "#Room 42"}

    time = ~U[2025-04-09 17:17:00Z]
    participants = [
      %TS.Participant{name: "Bob", role: :project_manager},
      %TS.Participant{name: "Petya", role: :developer},
      %TS.Participant{name: "Kate", role: :qa},
    ]
    agenda = [
      %TS.Topic{title: "Interview", description: "candidat for developer position"},
      %TS.Topic{title: "Direction", description: "disscuss main goals"},
    ]

    event = %TS.Event{
      title: "Weekly Team Meeting",
      place: place,
      time: time,
      participants: participants,
      agenda: agenda
    }

    TS.Event.add_participant(event, nil)
  end
end
