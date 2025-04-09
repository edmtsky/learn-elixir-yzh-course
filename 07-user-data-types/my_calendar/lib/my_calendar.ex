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
end
