# (24) 04-03 case, function clauses
defmodule ControlFlow do

  @moduledoc """
      iex> assert ControlFlow.handle({:cat, "Tom"}, :feed) == :ok
      :ok
      # feed the cat Tom

      iex> assert ControlFlow.handle2({:dog, "Spike"}, :feed) == :ok
      :ok
      # feed the dog Spike

      iex> assert ControlFlow.handle3({:shark, "Spike"}, :feed) == :ok
      :ok
      # do action 'feed' with animal '{:shark, "Spike"}'
  """

  # first approach nested branching
  def handle(animal, action) do
    case animal do
      {:dog, name} ->
        case action do
          :feed -> IO.puts("feed the dog #{name}")
          :pet -> IO.puts("pet the dog #{name}")
        end
      {:cat, name} ->
        case action do
          :feed -> IO.puts("feed the cat #{name}")
          :pet -> IO.puts("pet the cat #{name}")
        end
      {:mouse, name} ->
        case action do
          :feed -> IO.puts("feed the mouse #{name}")
          :pet -> IO.puts("pet the mouse #{name}")
        end
    end
  end

  # the same thing but rewritten in a flat representation
  # one level of nesting is much easier to read
  def handle2(animal, action) do
    case {animal, action} do
      {{:dog, name}, :feed} -> IO.puts("feed the dog #{name}")
      {{:dog, name}, :pet} -> IO.puts("pet the dog #{name}")
      {{:cat, name}, :feed} -> IO.puts("feed the cat #{name}")
      {{:cat, name}, :pet} -> IO.puts("pet the cat #{name}")
      {{:mouse, name}, :feed} -> IO.puts("feed the mouse #{name}")
      {{:mouse, name}, :pet} -> IO.puts("pet the mouse #{name}")
    end
  end

  def handle3({:dog, name}, :feed), do: IO.puts("feed the dog #{name}")
  def handle3({:dog, name}, :pet), do: IO.puts("pet the dog #{name}")
  def handle3({:cat, name}, :feed), do: IO.puts("feed the cat #{name}")
  def handle3({:cat, name}, :pet), do: IO.puts("pet the cat #{name}")
  def handle3({:mouse, name}, :feed), do: IO.puts("feed the mouse #{name}")
  def handle3({:mouse, name}, :pet), do: IO.puts("pet the mouse #{name}")

  def handle3(animal, action) do
    IO.puts("do action '#{action}' with animal '#{inspect(animal)}'")
  end
end
