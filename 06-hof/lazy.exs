defmodule Lazy do
  def get_longest_term(filename) do
    File.read!(filename)
    |> String.split("\n")
    |> Enum.filter(fn line -> line != "" end)
    |> Enum.map(fn line -> String.split(line, ":") end)
    |> Enum.map(fn [term, _] -> term end)
    |> Enum.map(fn term -> {String.length(term), term} end)
    |> Enum.max_by(fn {len, _term} -> len end)
    |> elem(1)
  end

  def get_longest_term_lazy(filename) do
    File.stream!(filename)
    |> Stream.filter(fn line -> line != "" end)
    |> Stream.map(fn line -> String.split(line, ":") end)
    |> Stream.map(fn [term, _] -> term end)
    |> Enum.map(fn term -> {String.length(term), term} end)
    |> Enum.max_by(fn {len, _term} -> len end)
    |> elem(1)
  end

  def test_data do
    [
      {"Bob", 24},
      {"Bill", 25},
      {"Kate", 26},
      {"Helen", 34},
      {"Yury", 16}
    ]
  end

  def make_table(data) do
    css_styles = Stream.cycle(["white", "gray"])
    iterator = Stream.iterate(1, fn i -> i + 1 end)

    rows =
      Stream.zip(css_styles, iterator)
      |> Stream.zip(data)
      # {{css_style, index},  {name, age}}
      |> Enum.map(fn {{css_style, index}, {name, age}} ->
        "<tr class='#{css_style}'><td>#{index}</td><td>#{name}</td><td>#{age}</td><tr>"
      end)
      |> Enum.join("\n")

    "<table>#{rows}</table>"
  end

  def make_table_2(users) do
    initial_state = {true, 1}

    unfolder = fn {odd, index} ->
      value = %{odd: odd, index: index}
      new_state = {not odd, index + 1}
      {value, new_state}
    end

    rows =
      Stream.unfold(initial_state, unfolder)
      |> Stream.zip(users)
      |> Enum.map(fn {state, user} ->
        css_style = if state.odd, do: "white", else: "gray"
        index = state.index
        {name, age} = user

        "<tr class='#{css_style}'><td>#{index}</td><td>#{name}</td><td>#{age}</td><tr>"
      end)
      |> Enum.join("\n")

    "<table>#{rows}</table>"
  end
end
