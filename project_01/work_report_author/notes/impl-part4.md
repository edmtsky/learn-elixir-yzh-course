### Part-4

что осталось сделать:
- обработку ошибок
- вывести отчёт по построенной модели


### Обработка ошибок

- ранее реализацию делал по happy-path

```elixir
  def add_day(line, {report, curr_month_id, _curr_day_id} = _acc) do
    {day_id, desc} = Integer.parse(String.trim(line))                # (1)
    # ...
  end
```
- 1. здесь может быть и невалидный ввод, который не получится распарсить в число

```elixir
  def add_task(line, {report, curr_month_id, curr_day_id}) do
    # todo not only a happy path
    {:ok, task} = parse_task(line)                                   # (2)
    # ...
  end

  # ...
  @spec parse_task(String.t()) :: {:ok, Task.t()} | {:error, any()}
  #                                                 ^^^^^^^^^^^^^^ (3)
  def parse_task(str) do
    #...
  end
```
- 2. и здесь тоже может быть ошибка, но пока её обработки вообще нет
- 3. хотя в типе уже прописали что возможна и ошибка.


### Теория - обработка ошибок

что вообще ожидаем от обработки ошибок?

проблемы с программой могут быть из-за 2х вещей:

1. невалидные входные данные.
2. неправильно описана логика работы программы.

корректность работы логики программы - это то, что разработчик может
контролировать и проверять например тестами. Тогда как неправильные(невалидные)
входные данные это то от чего никак не избавится.

А значит стоит задача предусмотреть некую обработку невалидных входных данных

Варианты реагирования программы на невалидный ввод:

- просто молча упасть и перестать работать - самое худшее что может быть
- упасть и просто сказать "невалидный ввод" без каких-либо деталей.
  это чуть лучше но не позволит пользователю найти причину его ошибки.
- упасть с выдачей подробной диагностики - с указанием конкретных строк где
  допущены ошибки.
- вообще не падать, невалидные данные проигнорировать и выдать результат по тому
  что удалось обработать, но при этом указав какие есть ошибки входных данных.

будем делать так чтобы выводился подробный отчёт где возникли ошибки.

вообще есть два подхода как обрабатывать ошибки:
- останавливаться на первой падая с предупреждением - тут ошибка
- дойти до конца и вывести список всех найденных ошибок

```elixir
  @spec parse(String.t()) :: Model.Report.t()
  #                                         ^^^^ сюда еще и список ошибок
  def parse(content) do
    # ...
```

Продумываем какие вообще ошибки могут быть:
- невалидный месяц
- невалидный день если нет валидного числа (номер дня)
- ошибка при парсинге таска - категория, время


смотрим реакцию на неправильный месяц

> test/sample/report-2.md
```
...
# April-ERROR

## 15 thu
[COMM] Daily Meeting - 19m
[DEV] TASK-19 make test data - 32m
...
```

```sh
iex -S mix
```
```elixir
iex> alias WorkReport.Parser, as: P
iex> P.parse(P.get_report2())
```
```
** (MatchError) no match of right hand side value: :error
    (work_report 0.1.0) lib/parser.ex:60: WorkReport.Parser.add_month/2
    (elixir 1.18.3) lib/enum.ex:2546: Enum."-reduce/3-lists^foldl/2-0-"/3
    iex:6: (file)
```

```elixir
  def add_month(line, {report, _curr_month_id, _curr_day_id}) do
    {:ok, month_id} = Month.get_month_id(line)                   # line: 60  <<
    month = Month.new(month_id, line)
    report = Report.add_month(report, month)
    {report, month_id, nil}
  end
```

т.к. из Month.get_month_id вернулся `:error`



Сначала определим сам тип ошибки:
(описав его в модуле модели)

```elixir
defmodule WorkReport.Model do
  @type error_t() :: {integer(), String.t()}      # +
  # ...
```


Добавляем в аккумулятор список под найденые ошибки

```elixir
defmodule WorkReport.Parser do
  # ...

  # @spec parse(String.t()) :: Model.Report.t()                        -
  @spec parse(String.t()) :: {Model.Report.t(), [Model.error_t()]}   # +
  def parse(content) do
    content
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.filter(fn line -> line != "" end)
    |> Enum.reduce(
      {Model.Report.new(), nil, nil, []},
      #                            ^^^^
      fn
        "# " <> line, acc -> add_month(line, acc)
        "##" <> line, acc -> add_day(line, acc)
        line, acc -> add_task(line, acc)
      end
    )
  end

  def add_month(line, {report, _curr_month_id, _curr_day_id, errors}) do
    #                                                        ^^^^^^
    #....                   vvvvvv
    {report, month_id, nil, errors}
  end

  def add_day(line, {report, curr_month_id, _curr_day_id, errors} = _acc) do
    #                                                     ^^^^^^
    #....                                   vvvvvv
    {updated_report, curr_month_id, day_id, errors}
  end

  def add_task(line, {report, curr_month_id, curr_day_id, errors}) do
    #                                                     ^^^^^^
    #....                                        vvvvvv
    {updated_report, curr_month_id, curr_day_id, errors}
  end
```

Убираю ошибку и проверяю что парсер всё еще работает

report2.md
```
# April
```

```elixir
iex> recompile
iex> P.parse(P.get_report2())
```

```elixir
{%WorkReport.Model.Report{
   months: [
     %WorkReport.Model.Month{
      #...
     }
}, 4, 16, []}
#         ^^ empty errors list
```

работает - значит можно идти делать реализацию обработки ошибки в названии месяца


```elixir
  def add_month(line, {report, _curr_month_id, _curr_day_id, errors}) do
    {:ok, month_id} = Month.get_month_id(line)
    month = Month.new(month_id, line)
    report = Report.add_month(report, month)
    {report, month_id, nil, errors}
  end
```

```elixir
  def add_month(line, {report, _curr_month_id, curr_day_id, errors}) do
    case Month.get_month_id(line) do
      {:ok, month_id} ->
        month = Month.new(month_id, line)
        report = Report.add_month(report, month)
        {report, month_id, nil, errors}

      :error ->
        error = {42, "invalid month #{line}"}
        {report, month_id, curr_day_id, [error | errors]}
    end
  end
```

проверяем что это работает:
(сделав сначала невалидное название месяца

```elixir
iex> recompile
iex> P.parse(P.get_report2())

{%WorkReport.Model.Report{
   months: [
     %WorkReport.Model.Month{
      #...
     }
 }, 3, 16, [{42, "invalid month April@@"}]}
```

добавление нумерации строк для отображения в ошибках


```elixir
iex> list = ["line1", "line2", "", "line3"]
["line1", "line2", "", "line3"]

iex> Enum.zip([1,2,3,4,5], list)
[{1, "line1"}, {2, "line2"}, {3, ""}, {4, "line3"}]

iex> 1..length(list)
1..4

iex> Enum.zip(1..length(list), list)
[{1, "line1"}, {2, "line2"}, {3, ""}, {4, "line3"}]

# безконечная коллекция
iex> nums = Stream.iterate(1, fn n -> n + 1 end)
#Function<64.126549445/2 in Stream.unfold/2>

iex> Enum.zip(nums, list)
[{1, "line1"}, {2, "line2"}, {3, ""}, {4, "line3"}]
```


```elixir

  @spec parse(String.t()) :: {Model.Report.t(), [Model.error_t()]}
  def parse(content) do
    lnums = Stream.iterate(1, fn n -> n + 1 end)

    content
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.zip_with(lnums, fn line, lnum -> {lnum, line} end)    # << (+)
    |> Enum.filter(fn {_, line} -> line != "" end)
    #                 ^^^^^^^^^
    |> Enum.reduce(
      {Model.Report.new(), nil, nil, []},
      fn
        {lnum, "# " <> line}, acc -> add_month(lnum, line, acc)   # << update
        {lnum, "##" <> line}, acc -> add_day(line, acc)           # <<
        # line, acc -> add_task(line, acc)                        # << - was
        {lnum, line}, acc -> add_task(line, acc)                  # << + new
      # ^^^^^^^^^^^^
      end
    )
  end
  # ...

  def add_month(lnum, line, {report, curr_month_id, curr_day_id, errors}) do
    #           ^^^^
    case Month.get_month_id(line) do
      {:ok, month_id} ->
        month = Month.new(month_id, line)
        report = Report.add_month(report, month)
        {report, month_id, nil, errors}

      :error ->
        error = {lnum, "invalid month #{line}"}
        #        ^^^^
        {report, curr_month_id, curr_day_id, [error | errors]}
    end
  end
```

```elixir
iex> recompile
iex> P.parse(P.get_report2())

{%WorkReport.Model.Report{
   months: [
     %WorkReport.Model.Month{
      #...
     }
 }, 3, 16, [{22, "invalid month April@@"}]}
#            ^^ lnum with error
```


### Ошибка в номере дня

test/sample/report-2.md
```md
## @@10 wed
```
```elixir
iex> recompile
iex> P.parse(P.get_report2())

** (MatchError) no match of right hand side value: :error
    (work_report 0.1.0) lib/parser.ex:75: WorkReport.Parser.add_day/2
    (elixir 1.18.3) lib/enum.ex:2546: Enum."-reduce/3-lists^foldl/2-0-"/3
    iex:21: (file)
```
место где падает
```elixir
  def add_day(line, {report, curr_month_id, _curr_day_id, errors} = _acc) do
    {day_id, desc} = Integer.parse(String.trim(line))             # lnum:75 <<<
    description = String.trim(desc)
    day = Day.new(day_id, desc)
    updated_report = Report.add_day(report, curr_month_id, day)
    {updated_report, curr_month_id, day_id, errors}
  end
```

обновляем код add_day по аналогии с add_month
```elixir
  def add_day(lnum, line, {report, curr_month_id, curr_day_id, errors} = _acc) do
    #         ^^^^
    case Integer.parse(String.trim(line)) do                          # +
      {day_id, desc} ->
        description = String.trim(desc)
        day = Day.new(day_id, desc)
        updated_report = Report.add_day(report, curr_month_id, day)
        {updated_report, curr_month_id, day_id, errors}

      :error ->
        error = {lnum, "invalid day#{line}"}
        #        ^^^^
        {report, curr_month_id, curr_day_id, [error | errors]}
    end
  end
```

проверка
```elixir
iex> recompile
iex> P.parse(P.get_report2())

{%WorkReport.Model.Report{
   months: [%WorkReport.Model.Month{ #...
             }
 }, 4, 16, [{12, "invalid day @@10 wed"}]}
```

добавляю новый сэмпл response-3 с ошибками и ф-ю для его быстрого вытаскивания:
Parse.get_report3()

```elixir
iex> recompile
iex> P.parse(P.get_report3())

{%WorkReport.Model.Report{
   months: [%WorkReport.Model.Month{ #...
             }
 }, 3, 16,
 [
   {35, "invalid task [DEV] TASK-19 fix - bug - 28m"},
   {34, "invalid category [DEV@@] TASK-19 investigate bug - 43m"},
   {22, "invalid month April@@"},
   {12, "invalid day @@10 wed"}
 ]}
```


улучшаем вывод отчёта и списка ошибок
```elixir
  @spec parse(String.t()) :: {Model.Report.t(), [Model.error_t()]}
  def parse(content) do
    lnums = Stream.iterate(1, fn n -> n + 1 end)

    content
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.zip_with(lnums, fn line, lnum -> {lnum, line} end)
    |> Enum.filter(fn {_, line} -> line != "" end)
    |> Enum.reduce(
      {Model.Report.new(), nil, nil, []},
      fn
        {lnum, "# " <> line}, acc -> add_month(lnum, line, acc)
        {lnum, "##" <> line}, acc -> add_day(lnum, line, acc)
        {lnum, line}, acc -> add_task(lnum, line, acc)
      end
    )
    |> then(fn {report, _, _, errors} -> {report, Enum.reverse(errors)} end) #<<
  end
```

- `then` - позволяет "вставить" анонимную функцию в пайплайн

```elixir
iex> repompile
iex> P.parse(P.get_report3())

{%WorkReport.Model.Report{}
  # ...
,
...
 [
   {12, "invalid day @@10 wed"},
   {22, "invalid month April@@"},
   {34, "invalid category [DEV@@] TASK-19 investigate bug - 43m"},
   {35, "invalid task [DEV] TASK-19 fix - bug - 28m"}
 ]}
```


```sh
mix test --exclude=integration
```
(так как интеграционные пока сломаны и не проходят)



