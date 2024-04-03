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

  # catch all
  def handle3(animal, action) do
    IO.puts("do action '#{action}' with animal '#{inspect(animal)}'")
  end

  # Part 2 (25) 04-04 guards

  #
  # Guards

  def handle4(animal) do
    case animal do
      {:dog, name, age} when age <= 2 ->
        IO.puts("dog #{name} is an young dog")

      {:dog, name, _age} ->
        IO.puts("dog #{name} is an adult")

      {:cat, name, age} when age < 10 ->
        IO.puts("dog #{name} is an old cat")

      {:cat, name, _age} ->
        IO.puts("dog #{name} is not so old")
    end
  end

  #
  # Guards + Function Clauses

  def handle5({:dog, name, age}) when age <= 2 do
    IO.puts("dog #{name} is an young dog")
  end

  def handle5({:dog, name, _age}) do
    IO.puts("dog #{name} is an adult")
  end

  def handle5({:cat, name, age}) when age < 10 do
    IO.puts("dog #{name} is an old cat")
  end

  def handle5({:cat, name, _age}) do
    IO.puts("dog #{name} is not so old")
  end

  # Chains of Guards
  def handle6({:library, rating, books}) when rating > 4 and length(books) > 2 do
    IO.puts("a good library")
  end

  def handle6({:library, rating, books}) when rating > 4 or length(books) > 2 do
    IO.puts("no so good library")
  end

  def handle6({:library, _rating, _books}) do
    IO.puts("not recomended")
  end

  #
  # Подключение макросов из модуля Integer
  require Integer

  def handle7(a) when Integer.is_odd(a) do
    IO.puts("#{a} is odd")
  end

  def handle7(a) when Integer.is_even(a) do
    IO.puts("#{a} is even")
  end

  #
  # Errors in Guards

  def handle8(a, b) when 10 / a > 2 do
    {:clause_1, b}
  end

  def handle8(_a, b) do
    {:clause_2, 10 / b}
  end

  #
  # Why Guards not raise exceptions, but just return false

  # def handle9(m) when is_map(m) and map_size(m) > 2 do
  def handle9(m) when map_size(m) > 2 do
    IO.puts("big map")
  end

  def handle9(_m) do
    IO.puts("not a big map (or not a map)")
  end
end
