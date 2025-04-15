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



## Part-2

Модель для описания одного дня содержащего задачи

- имеет description - это номер для и его короткое имя
- списков задач

```elixir
defmodule WorkReport.Model do

  defmodule Day do
    @type t :: %__MODULE__{
            id: integer(),
            description: String.t(),
            tasks: [Task.t()]
          }

    @enforce_keys [:id]
    defstruct [:id, :description, :tasks]

    def new(id, description \\ "", tasks \\ []) do
      %__MODULE__{
        id: id,
        description: description,
        tasks: tasks
      }
    end

    @spec add_task(t(), Task.t()) :: t()
    def add_task(day, task) do
      # %__MODULE__{day | tasks: [task | day.tasks]}
      %__MODULE__{day | tasks: day.tasks ++ [task]}
    end
  end
```

- две косые обратные черты - это способ указать значение по умолчанию прямо
  в сигнатуре функции. т.е. здесь description будет по умолчанию пустой строкой.

т.к. у нас здесь задач будет не очень много пойдём на компромис с
производительностью и будет добавлять новые задачи в конец списка (list1 ++ list2)
а не в начало списка `[elm | list1]` что намного эффективнее, но потребовало бы
дальнейшего разворачивания списка при отображении.

проверяем работоспособность руками через консоль
```sh
iex -S mix
```
(alias-ы добавляются атоматически через .iex.exs файл)
```elixir
iex> day = M.Day.new(1, "1 mon")
%WorkReport.Model.Day{id: 1, description: "1 mon", tasks: []}

iex> task = M.Task.new("DEV", "somde desc", 10)
%WorkReport.Model.Task{category: "DEV", description: "somde desc", time: 10}

iex> day = M.Day.add_task(day, task)
%WorkReport.Model.Day{
  id: 1,
  description: "1 mon",
  tasks: [
    %WorkReport.Model.Task{category: "DEV", description: "somde desc", time: 10}
  ]
}
```


### Продумываем как написать парсер для Task

можно было бы взять и разделить входной файл на месяцы и дни, и затем весь текст,
содержащий один конкретный день парсить в сущность День. Но есть и другой подход
- с построчным парсинго строк, походу парсинга создавая сущности прямо на ходу,
по тому что там описано в строке.


продумываем что понадобиться для построчного парсинга всего файла

еще надо будет
- сущность День - готово
- сущность Месяц
- ф-ии добавления Дня в Месяц, и Таски в День(текущий)

дописываем модели

```elixir
defmodule WorkReport.Model do
  # ...

  defmodule Day do
    @type t :: %__MODULE__{
            id: integer(),
            description: String.t(),
            tasks: [Task.t()]
          }

    @enforce_keys [:id]
    defstruct [:id, :description, :tasks]

    @spec(integer(), String.t(), Task.t()) :: t()
    def new(id, description \\ "", tasks \\ []) do
      %__MODULE__{
        id: id,
        description: description,
        tasks: tasks
      }
    end

    @spec add_task(t(), Task.t()) :: t()
    def add_task(day, task) do
      # %__MODULE__{day | tasks: [task | day.tasks]}
      %__MODULE__{day | tasks: day.tasks ++ [task]}
    end
  end

  defmodule Month do
    @type t :: %__MODULE__{
            id: integer(),
            description: String.t(),
            days: [Day.t()]
          }

    @enforce_keys [:id]
    defstruct [:id, :description, :days]

    @spec(integer(), String.t(), Day.t()) :: t()
    def new(id, description \\ "", days\\ []) do
      %__MODULE__{
        id: id,
        description: description,
        days: days
      }
    end

    @spec add_day(t(), Day.t()) :: t()
    def add_day(month, day) do
      %__MODULE__{month | days: month.days ++ [day]}
    end
  end

  defmodule Report do
    @type t :: %__MODULE__{
            months: [Month.t()]
          }

    @enforce_keys [:months]
    defstruct [:months]

    @spec([Month.t()])
    def new(months \\ []) do
      %__MODULE__{
        months: months
      }
    end

    @spec add_month(t(), Month.t()) :: t()
    def add_month(report, month) do
      %__MODULE__{report | months: report.months ++ [month]}
    end

    # ... здесь то самое интересное API для добавления месяца, дня и задачи

  end
end
```

API:
```elixir
  defmodule Report do

    @spec add_day(t(), integer(), Day.t()) :: t()
    def add_day(report, month_id, day) do
      # ... здесь нужно по id Месяца найти его и добавить в него День
    end

    @spec add_task(t(), integer(), integer(), Task.t()) :: t()
    def add_task(report, month_id, day_id, task) do
      # ... здесь нужно добавить Здачу в конкретный День, внутри конкретного Месяца
    end
  end
```


продумываем что выбрать Map или List для хранения сущностей
нам надо будет искать одни сущности внутри других сущностей по их id
Может выбрать Map? но у нас сущностей будет не много поэтому норм взять и просто
список а не мапу.


Поиск месяца внутри отчёта по его id (порядковый номер месяца)

```elixir
    @spec add_day(t(), integer(), Day.t()) :: t()
    def add_day(report, month_id, day) do
      # достать месяц из списка по его id (happy-path)
      month = Enum.find(report.months, fn month -> month.id = month_id end)
      # ...
    end
```

пока пишем по Happy path без обработки ошибок

Enum.find - может и не найти нужный нам месяц поэтому здесь по хорошему еще
нужно будет дописать вариант с ошибкой month_not_found


как земенить месяц в списке по его id

```elixir
    @spec add_day(t(), integer(), Day.t()) :: t()
    def add_day(report, month_id, day) do
      month = Enum.find(report.months, fn month -> month.id = month_id end)
      # ну это просто - добавить день в нужный месяц
      month = Month.add_day(month, day)
      # ... теперь нужно заменить старый месяц на обновлённый
    end
```
новой задача

### Как заменить элемент списка на другой элемент?

```elixir
    @spec add_day(t(), integer(), Day.t()) :: t()
    def add_day(report, month_id, day) do
      month = Enum.find(report.months, fn month -> month.id == month_id end)
      # ну это просто - добавить день в нужный месяц
      month = Month.add_day(month, day)
      # ... теперь нужно заменить старый месяц на обновлённый
    end
```

лучше сразу сделать это через Enum.map вот так:
```elixir
    @spec add_day(t(), integer(), Day.t()) :: t()
    def add_day(report, month_id, day) do
      months = Enum.map(report.months,
        fn month ->
          if month.id == month_id do  # своего рода поиск эл-та по индексу
            Month.add_day(month, day)
          else
            month # тоже значение без изменений
          end
        end)

      %__MODULE__{report | months: months}
    end
```
- здесь суть в том, что проходим весь список месяцев и если тот месяц который
нужно обновить совпадает с текущим эл-том в списке то добавляем в него новый день
а все остальные элементы просто оставляем как есть


тест для проверки нового функционала:
```elixir
defmodule ModelTest do
  use ExUnit.Case

  alias WorkReport.Parser, as: P
  alias WorkReport.Model.{Report, Month, Day, Task}

  test "add task to report " do
    month1 = Month.new(1, "Jan")
    month2 = Month.new(2, "Feb")

    report =
      Report.new()
      |> Report.add_month(month1)
      |> Report.add_month(month2)

    assert report == %Report{months: [month1, month2]}

    day1 = Day.new(1, "1 mon")
    day2 = Day.new(2, "2 tue")
    report = Report.add_day(report, 1, day1)
    report = Report.add_day(report, 1, day2)

    day3 = Day.new(3, "3 wed")
    day4 = Day.new(4, "4 tru")
    report = Report.add_day(report, 2, day3)
    report = Report.add_day(report, 2, day4)

    assert report == %Report{
             months: [
               %Month{id: 1, description: "Jan", days: [day1, day2]},
               %Month{id: 2, description: "Jan", days: [day3, day4]}
             ]
           }
  end
end
```

реализация добавления задачи в отчёт по month_id и day_id
(это нужно будет для построчного парсера)

```elixir
  defmodule Report do
    # ...

    @spec add_task(t(), integer(), integer(), Task.t()) :: t()
    def add_task(report, month_id, day_id, task) do
      months =
        Enum.map(
          report.months,
          fn month ->
            if month.id == month_id do
              days = Enum.map(month.days, fn day ->
                if day.id == day_id do
                  Day.add_task(day, task)
                else
                  day
                end
              end)
              %Month{month | days: days} # обновление значения в struct(map)
            else
              month
            end
          end
        )

      %__MODULE__{report | months: months}
    end
  end
```

тест:
```elixir
  test "add task to report " do
    day1 = Day.new(1, "1 mon")
    day2 = Day.new(2, "2 tue")
    month1 = Month.new(1, "Jan") |> Month.add_day(day1) |> Month.add_day(day2)

    day3 = Day.new(3, "3 wed")
    day4 = Day.new(4, "4 tru")
    month2 = Month.new(2, "Feb") |> Month.add_day(day3) |> Month.add_day(day4)

    report = Report.new() |> Report.add_month(month1) |> Report.add_month(month2)

    task1 = Task.new("DEV", "some desc", 30)
    month_id = 1
    day_id = 2
    report = Report.add_task(report, month_id, day_id, task1)

    updated_day2 = %Day{id: 2, description: "2 tue", tasks: [task1]}
    #                                                        ^^^^^

    assert report == %Report{
             months: [
               %Month{id: 1, description: "Jan", days: [day1, updated_day2]},
               %Month{id: 2, description: "Feb", days: [day3, day4]}
             ]
           }
  end
```

рефакторим код - уменьшаем вложенность в Report.add_task
выносим часть кода в новую ф-ю Month.add_task


```elixir
  defmodule Month do
    # ...

    @spec add_task(t(), integer(), Task.t()) :: t()
    def add_task(month, day_id, task) do           # +++ << for Report.add_task
      days = Enum.map(month.days, fn day ->
            if day.id == day_id do
              Day.add_task(day, task)
            else
              day
            end
          end
        )

      %__MODULE__{month | days: days}
    end
  end

  defmodule Report do
    # ...

    @spec add_task(t(), integer(), integer(), Task.t()) :: t()
    def add_task(report, month_id, day_id, task) do
      months =
        Enum.map(
          report.months,
          fn month ->
            if month.id == month_id do
              Month.add_task(month, day_id, task) # <<<<
            else
              month
            end
          end
        )

      %__MODULE__{report | months: months}
    end
  end
```

обновляем тесты и проверяем - ошибок нет



### Part-3

идея реализации парсера
- идём построчно по файлу

```elixir
# Parser

  # временный хэлпер чтобы можно было удобно вытащить отчёт из консоли
  def get_report1() do
    {:ok, content} = File.read("test/sample/report-1.md")
    content
  end

  @spec parse(String.t()) :: Model.Report.t()
  def parse(content) do
    content
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.filter(fn line -> line != "" end)
    # ...
  end
```
Это подготовка которая берёт входной текст, разбивает на части, удаляет
пустые символы с конца строк и удаляет пустые строки

реализация свёртки по списку строк

и для свёртки нужен аккумулятор хранящий
- Report
- month_id (текущего месяца)
- day_id (текущего дня)

```elixir
  @spec parse(String.t()) :: Model.Report.t()
  def parse(content) do
    content
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.filter(fn line -> line != "" end)
    |> Enum.reduce({Model.Report.new(), nil, nil}, fn line, acc -> :job end)
    #              ^^^^^^^^ initial_acc^^^^^^^^^^      item acc
  end
```

вариантов будет несколько поэтому сразу вывавниваем под несколько тел фу-ий

```elixir
  @spec parse(String.t()) :: Model.Report.t()
  def parse(content) do
    content
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.filter(fn line -> line != "" end)
    |> Enum.reduce({Model.Report.new(), nil, nil},
      fn
        "# " <> line, acc -> add_month(line, acc)
        "##" <> line, acc -> add_day(line, acc)
        line, acc -> add_task(line, acc)
      end)
  end
```

```elixir
  def add_month(line, acc) do
    #....
  end
```

то как сделал бы я:
```elixir
  def add_month(line, {report, month_id, day_id}) do
    {:ok, month_id, desc} = parse_month(line) # todo implement parse_month
    month = Model.Month.new(month_id, desc)
    report.add_month(month)                   # ошибка это не ООП
    {report, month_id, nil}
  end
```

решение автора курса:
```elixir
  def add_month(line, {report, _curr_month_id, _curr_day_id}) do
    month_id = 1 # TODO implement by month name
    month = Model.Month.new(month_id, line)
    report = Model.Report.add_month(report, month)
    {report, month_id, nil}
  end
```

чтобы протестировать работу add_month добавляем заглушку
```elixir
  def add_day(_line, acc) do
    acc
  end

  def add_task(_line, acc) do
    acc
  end
```

```elixir
iex> recompile
iex> P.parse(report)
{%WorkReport.Model.Report{
   months: [%WorkReport.Model.Month{id: 1, description: "May", days: []}]
 }, 1, nil}
```
- curr_month_id - 1
- curr_day_id - nil

пробуем парсить отчёт с двумя месяцами

```elixir
  def get_report1() do
    {:ok, content} = File.read("test/sample/report-2.md")
    content
  end
```

```elixir
iex> report = P.get_report2()
# ... полный текст отчёта

iex> P.parse(report)
{%WorkReport.Model.Report{
   months: [
     %WorkReport.Model.Month{id: 1, description: "March", days: []},
     %WorkReport.Model.Month{id: 1, description: "April", days: []}
   ]
 }, 1, nil}
```

### реализация парсинга month_id
имя месяца в его номер

моя реализация:
```elixir
  defmodule Month do
    @month_names [ "january", "february", "march", "april", "may", "june",
    "july", "august", "september", "october", "november", "december"]

    # ...

    @spec get_month_num(String.t()) :: {:ok, integer()} | {:error, any()}
    def get_month_num(month_name) do
      month_name = String.downcase(month_name)

      case Enum.find_index(@month_names, fn m -> m == month_name end) do
        nil -> {:error, :invalid_month_name}
        n -> {:ok, n + 1}
      end
    end
  end

# test

  test "get_month_num" do
    assert Month.get_month_num("january") == {:ok, 1}
    assert Month.get_month_num("January") == {:ok, 1}
    assert Month.get_month_num("December") == {:ok, 12}
    assert Month.get_month_num("not-a-month") == {:error, :invalid_month_name}
  end
```

реализация автора:
```elixir
    @spec months() :: map()
    def months() do
      %{
        1 => "January",
        2 => "February",
        3 => "March",
        4 => "April",
        5 => "May",
        6 => "June",
        7 => "July",
        8 => "August",
        9 => "September",
        10 => "October",
        11 => "November",
        12 => "December"
      }
    end

    @spec get_month_id(String.t()) :: {:ok, integer()} | :error
    def get_month_id(month_name) do
      month_ids = Enum.reduce(months(), %{}, fn {k, v}, acc ->
        Map.put(acc, v, k)
      end)

      Map.fetch(month_ids, month_name)
    end

    # pipe:
    def get_month_id(month_name) do
      Enum.reduce(months(), %{}, fn {k, v}, acc -> Map.put(acc, v, k) end)
      |> Map.fetch(String.capitalize(month_name))
    end
```

```elixir
  def add_month(line, {report, _curr_month_id, _curr_day_id}) do
    # todo not only a happy path
    {:ok, month_id} = Model.Month.get_month_id(line)
    month = Model.Month.new(month_id, line)
    report = Model.Report.add_month(report, month)
    {report, month_id, nil}
  end
```

проверяем что появились правильные month_id
```elixir
iex> recompile
...
iex> P.parse(report)
{%WorkReport.Model.Report{
   months: [
     %WorkReport.Model.Month{id: 3, description: "March", days: []},
     %WorkReport.Model.Month{id: 4, description: "April", days: []}
   ]
 }, 4, nil}
```

```elixir
# defmodule Parser
 alias WorkReport.Model.{Report, Month, Day, Task}
```

реализация добавления дня при парсинге

моя реализация:
```elixir
  def add_day(line, {report, curr_month_id, _curr_day_id} = _acc) do
    case String.split(" ", 2) do
      [num, desc] ->
        day_id = String.to_integer(num)
        day = Day.new(day_id, desc)
        update_report = Report.add_day(report, curr_month_id, day)
        {update_report, curr_month_id, day_id}
      _ ->
        :do  #??
    end
  end
```


реализация автора
на основе Integer.parse:
```elixir
iex> Integer.parse("01 tue")
{1, " the"}
```

```elixir
  def add_day(line, {report, curr_month_id, _curr_day_id} = _acc) do
    {day_id, desc} = Integer.parse(String.trim(line))
    description = String.trim(desc)
    day = Day.new(day_id, desc)
    updated_report = Report.add_day(report, curr_month_id, day)
    {updated_report, curr_month_id, day_id}
  end
```


```elixir
iex> recompile
iex> P.parse(P.get_report2())
{%WorkReport.Model.Report{
   months: [
     %WorkReport.Model.Month{
       id: 3,
       description: "March",
       days: [
         %WorkReport.Model.Day{id: 9, description: " tue", tasks: []},
         %WorkReport.Model.Day{id: 10, description: " wed", tasks: []}
       ]
     },
     %WorkReport.Model.Month{
       id: 4,
       description: "April",
       days: [
         %WorkReport.Model.Day{id: 15, description: " thu", tasks: []},
         %WorkReport.Model.Day{id: 16, description: " fri", tasks: []}
       ]
     }
   ]
 }, 4, 16}
```

реализация добавления задачи при парсинге файла
```elixir

  def add_task(line, {report, curr_month_id, curr_day_id}) do
    # todo not only a happy path
    {:ok, task} = parse_task(line)

    updated_report = Report.add_task(report, curr_month_id, curr_day_id, task)
    {updated_report, curr_month_id, curr_day_id}
  end
```

проверка
```elixir
iex> recompile
...
iex> P.parse(P.get_report2())
{%WorkReport.Model.Report{
   months: [
     %WorkReport.Model.Month{
       id: 3, description: "March",
       days: [
         %WorkReport.Model.Day{
           id: 9, description: " tue",
           tasks: [
             %Task{ category: "DEV", description: "TASK-15 implement feature", time: 42 },
             %Task{ category: "COMM", description: "Daily Meeting", time: 24 },
             %Task{ category: "DEV", description: "TASK-15 implement", time: 25 },
             %Task{ category: "COMM", description: "Big Meeting", time: 73 },
             %Task{ category: "COMM", description: "Yet another meeting", time: 53 },
             %Task{ category: "DEV", description: "TASK-15 implement", time: 27 },
             %Task{ category: "DEV", description: "TASK-15 tests", time: 45 }
           ]
         },
         %WorkReport.Model.Day{
           id: 10, description: " wed",
           tasks: [
             %Task{ category: "DEV", description: "Review Pull Requests", time: 17 },
             %Task{ category: "COMM", description: "Sprint Planning", time: 60 },
             %Task{ category: "DEV", description: "TASK-18 fix errors", time: 15 },
             %Task{ category: "DEV", description: "TASK-18 tests", time: 35 },
             %Task{ category: "DEV", description: "TASK-18 tests", time: 45 },
             %Task{ category: "DEV", description: "TASK-18 tests", time: 43 },
             %Task{category: "DOC", description: "TASK-18 write api doc", time: 24}
           ]
         }
       ]
     },
     %WorkReport.Model.Month{
       id: 4, description: "April",
       days: [
         %WorkReport.Model.Day{
           id: 15, description: " thu",
           tasks: [
             %Task{ category: "COMM", description: "Daily Meeting", time: 19 },
             %Task{ category: "DEV", description: "TASK-19 make test data", time: 32 },
             %Task{ category: "DEV", description: "TASK-19 implementation", time: 64 },
             %Task{ category: "DEV", description: "TASK-19 implementation", time: 24 },
             %Task{ category: "DEV", description: "TASK-19 tests", time: 93 }
           ]
         },
         %WorkReport.Model.Day{
           id: 16, description: " fri",
           tasks: [
             %Task{ category: "DEV", description: "TASK-20 implementation", time: 17 },
             %Task{ category: "COMM", description: "Daily Meeting", time: 22 },
             %Task{ category: "DEV", description: "TASK-19 investigate bug", time: 43 },
             %Task{ category: "DEV", description: "TASK-19 fix bug", time: 28 },
             %Task{ category: "DEV", description: "TASK-20 implementation", time: 38 },
             %Task{ category: "DEV", description: "TASK-20 implementation", time: 40 },
             %Task{ category: "DEV", description: "TASK-20 test", time: 18 },
             %Task{ category: "DOC", description: "TASK-21 read requirements", time: 32 }
           ]
         }
       ]
     }
   ]
 }, 4, 16}
```

