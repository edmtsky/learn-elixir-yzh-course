# Заметки по реализации проекта на основе решения автора (по видео)

## Part-1

### реализация парсера строки в минуты

```elixir
defmodule WorkReport.Parser do

  @spec parse_time(String.t()) :: integer()
  def parse_time(time_str) do
    time_str
    |> String.split(" ")
    |> Enum.map(&parse_time_item/1)
  end

  def parse_time_item(item) do
    Integer.parse(item) # [10, "m"]
  end
end
```

```sh
iex -S mix
```

```elixir
iex> alias WorkReport.Parser, as: P
iex> P.parse_time("1h 30m")
[{1, "h"}, {30, "m"}]
```

```elixir
  def parse_time_item(item) do
    case Integer.parse(item) do
      {n, "h"} -> n * 60
      {n, "m"} -> n
      _ -> 0 # (1)
    end
  end
```

- 1 в случае невалидных значений просто возвращаем 0 игнорируя ошибки

При реализации данного учебного проекта мы еще будем делать обработку ошибок
при парсинге, но не настолько досконально как бы это следовало бы делать в
реальном рабочем проекте. - Учебный проект должен быть чуть попроще чтобы не
закопаться слишком глубоко в мелких деталях, а больше работать по сути.


```elixir
iex> recompile
Compiling 1 file (.ex)
Generated work_report app
:ok

iex> P.parse_time("1h 30m")
[60, 30]
```

осталось просуммировать числа

думал сделать через
```elixir
[60, 30]
|> Enum.reduce(0, fn n, sum -> sum + n end)
```
автор сделал через
```elixir
Enum.sum()
```

Проверяем реализацию parse_time через готовые тесты
```sh
mix test test/parser_test.exs

Running ExUnit with seed: 142177, max_cases: 8

.
Finished in 0.03 seconds (0.00s async, 0.03s sync)
1 test, 0 failures
```


### format_time - форматирование времени(в минутах) в строку

```elixir
defmodule WorkReport.Formatter do

  @spec format_time(integer) :: String.t()
  def format_time(time) do
    hours = div(time, 60) # целочисленное деление
    minutes = rem(time, 60) # остаток от деления на 60

    case {hours, minutes} do
      {0, 0} -> "0"
      {h, 0} -> "#{h}h"
      {0, m} -> "#{m}m"
      {h, m} -> "#{h}h #{m}m"
    end
  end
end
```


### продумываем дальнейшую реализацию проекта

Упрощенно
- нужно распарсить весь тектовый markdown файл
- представить все сущности из этого входного файла, через Эликсировские
  структуры данных(Struct)


Какие у нас есть сущности?
- весь отчёт в целом, состоящий из нескольких месяцев
- месяц, состоящий из отчётов по конкретным дням
- день, состоящий из задач
- задача, состоящая из
  - категория
  - описание
  - минуты


То есть можно сказать что самая малая сущность - время в минутах потраченное на
конкретную задачу


Будем реализовывать сущности снизу вверх (от задач к отчёту)


### начинаем реализацию первой сущности - задача


lib/model.ex
```elixir
defmodule WorkReport.Model do
  defmodule Task do
    @type t :: %__MODULE__{
            category: String.t(),  # в идеале нужен Enum
            description: String.t(),
            time: non_neg_integer()
          }

    @enforce_keys [:category, :description, :time]
    defstruct [:category, :description, :time]

    def new(category, description, time) do
      %__MODULE__{
        category: category,
        description: description,
        time: time
      }
    end
  end
end
```
mix compile (убедиться что ошибок нет)

Начинаем реализацию с теста

```elixir
defmodule ParserTest do
  use ExUnit.Case
  alias WorkReport.Parser, as: P

  # ...

  test "parse task" do
    str = "[DEV] some desc - 42m"
    task = %Task{
        category: "DEV",
        description: "some desc",
        time: 42
    }
    assert {:ok, task} == Parser.parse_task(str)
  end
```

Здесь уже будем обрабатывать и ошибки тоже

```elixir
defmodule WorkReport.Parser do
  alias WorkReport.Model.Task

  # ...

  @spec parse_task(String.t()) :: {:ok, Task.t()} | {:error, any()}
  def parse_task(str) do
    # ...
  end
```

Принцип парсинга
- отделяем первое слово
- вытаскиваем из кавычке
- обрезаем по ` - ` с конца строки (время)

```elixir
str = "[DEV] some desc - 42m"
```

```elixir
iex> String.split(str, " ")
["[DEV]", "some", "desc", "-", "42m"]    # нужно только 1е слово..

iex> String.split(str, " ", parts: 2)
["[DEV]", "some desc - 42m"]
```


```elixir
  @spec parse_task(String.t()) :: {:ok, Task.t()} | {:error, any()}
  def parse_task(str) do
    [first_word, rest] = String.split(str, " ", parts: 2)
    category = first_word |> String.trim("[") |> String.trim("]")
    # ...
  end
```
проверяю должно вывести имя категории
```elixir
iex> P.parse_task("[DEV] some desc - 42m")
"DEV"
```

Надо как-то проверить валидность категории, и если такой нет - ошибка
нужен список известных категорий - размещаем в модели

```elixir
defmodule WorkReport.Model do

  @doc """
  Returns a list of all valid categories
  """
  def categories() do
    [ "COMM", "DEV", "OPS", "DOC", "WS", "EDU" ]
  end

  #...
```


```elixir
defmodule WorkReport.Parser do
  alias WorkReport.Model.Task
  alias WorkReport.Model                                              # +

  #...

  @spec parse_task(String.t()) :: {:ok, Task.t()} | {:error, any()}
  def parse_task(str) do
    [first_word, rest] = String.split(str, " ", parts: 2)
    category = first_word |> String.trim("[") |> String.trim("]")

    with true <- category in Model.categories, do                      # +
      # ...
    end
  end
```
логика:
 - категория есть в списке - идём парсить дальше
 - если нет - валимся из макроса `with` с ошибкой


```elixir
  @spec parse_task(String.t()) :: {:ok, Task.t()} | {:error, any()}
  def parse_task(str) do
    [first_word, rest] = String.split(str, " ", parts: 2)
    category = first_word |> String.trim("[") |> String.trim("]")

    with true <- category in Model.categories,
         [desc, time_str] <- String.split(rest, " - ") do
      time = parse_time(time_str)
      {:ok, Task.new(category, desc, time)}
    else                                         # обработка ошибок
      false -> {:error, :invalid_category}
      _ -> {:error, :invalid_task}
    end
  end
```
`with ... do else` - внутри else описываем случае bad-match и по ним выдаём
что пошло не так - либо плохая категория либо само тело задачи

(в реальном проекте и парсинг времени time тоже бы было внутри with-do)

```elixir
iex> P.parse_task("[DEV] some desc - 42m")
{:ok,
 %WorkReport.Model.Task{category: "DEV", description: "some desc", time: 42}}

iex> P.parse_task("[SOME] some desc - 42m")
{:error, :invalid_category}

iex> P.parse_task("[DEV] some - desc - 42m")
{:error, :invalid_task}
```

проверяем на тесте - проходит, ошибок нет.

