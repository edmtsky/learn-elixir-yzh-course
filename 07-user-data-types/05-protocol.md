## 07.06 Протокол

Вводная про протоколы

Помним, что есть модуль Enum, в котором есть HOF (функции высшего порядка) такие
как filter, map, reduce и проч, которые работают с разными коллекциями:

```elixir
# обходим список
iex> Enum.map([1,2,3], fn i -> i * 2 end)
[2, 4, 6]

# обходим Range(Диапазон)
iex> Enum.map(1..10, fn i -> i * 2 end)
[2, 4, 6, 8, 10, 12, 14, 16, 18, 20]

# обходим Range(Словарь) меняя местами ключ-значение
iex> Enum.map(%{a: 42, b: 100}, fn {k, v} -> {v, k} end)
[{42, :a}, {100, :b}]

# и резульат из Keyword-List преобразуем в Map
iex> Enum.map(%{a: 42, b: 100}, fn {k, v} -> {v, k} end) |> Map.new()
%{42 => :a, 100 => :b}
```

Вопрос: как это работает? Почему одна и та же функция Enum.map умеет обрабатывать
разные типы данных: списки, диапазоны, мапы?

Работает это через реализацию протокола Enumerable.
Протокол Enumerable определяет кокретные функции, которые обязательно должны быть
реализованы конкретным типом коллекции. А модуль Enum уже дальше пользуется этим
протоколом Enumerable, что позволяет ему работать с любой реализацией данного
протокола(как интерфейсы в java)

Если бы у нас вообще не было "протоколов" и нужно было самим написать модуль
Enum:

```elixir
defmodule Enum do
  def map(collection, f) when is_list(collection), do ...
  def map(collection, f) when is_map(collection), do ...
  def map(collection, f) when is_binary(collection), do ...

  def reduce(collection, f) when is_list(collection), do ...
  def reduce(collection, f) when is_map(collection), do ...
  def reduce(collection, f) when is_binary(collection), do ...
  # ...
```
то есть для каждой конкретной коллекции(списки, мапы, бинарные строки) нужно
было бы делать свою кокретную реализацию прямо в модуле Enum.
При этом явно дублируя по сути один и тот же код.

Протоколы это чисто Эликсировская вещь и в Эрланге их нет, есть только Behaviour
И поэтому в эрланге модуль :maps написан примерно так:
(свои реализации под конкретные коллекции)
```erlang
:maps.filter
:maps.map
:list.map
:list.fold
```

И протокол - это способ избежать такого дублирования, введя своего рода уровень
абстракции.

```elixir
defmodule Set do
  impl Enumerable  # говорим что наш модуль Set реализует протокол Enumerable
  # ...
end
```


если устанавливал эликсир через asdf то посмотреть исходники модуля Enum можно так:
```sh
nvim ~/.asdf/installs/elixir/1.18.3-otp-26/lib/elixir/lib/enum.ex
```

В самом начале модуля идёт определение протокола:
```elixir
defprotocol Enumerable do
  @moduledoc """
  Enumerable protocol used by `Enum` and `Stream` modules.

  When you invoke a function in the `Enum` module, the first argument
  is usually a collection that must implement this protocol.
  For example, the expression `Enum.map([1, 2, 3], &(&1 * 2))`
  invokes `Enumerable.reduce/3` to perform the reducing operation that
  builds a mapped list by calling the mapping function `&(&1 * 2)` on
  every element in the collection and consuming the element with an
  accumulated list.

  Internally, `Enum.map/2` is implemented as follows:

      def map(enumerable, fun) do
        reducer = fn x, acc -> {:cont, [fun.(x) | acc]} end
        Enumerable.reduce(enumerable, {:cont, []}, reducer) |> elem(1) |> :lists.reverse()
      end
  ....
  """
  @typedoc since: "1.14.0"
  @type t(_element) :: t()                     # ? Enumerable.t()
  # ...
  @spec reduce(t, acc, reducer) :: result
  def reduce(enumerable, acc, fun)

  @spec count(t) :: {:ok, non_neg_integer} | {:error, module}
  def count(enumerable)

  @spec member?(t, term) :: {:ok, boolean} | {:error, module}
  def member?(enumerable, element)

  @spec slice(t) ::
          {:ok, size :: non_neg_integer(), slicing_fun() | to_list_fun()}
          | {:error, module()}
  def slice(enumerable)
end

defmodule Enum do
   # ...
```

а вот пример того как обьявлены функция Enum.map
```elixir
  @doc """
  Returns a list where each element is the result of invoking
  `fun` on each corresponding element of `enumerable`.

  For maps, the function expects a key-value tuple.

  ## Examples

      iex> Enum.map([1, 2, 3], fn x -> x * 2 end)
      [2, 4, 6]

      iex> Enum.map([a: 1, b: 2], fn {k, v} -> {k, -v} end)
      [a: -1, b: -2]

  """
  @spec map(t, (element -> any)) :: list  # t --> Enumerable.t?
  def map(enumerable, fun)

  def map(enumerable, fun) when is_list(enumerable) do
    :lists.map(fun, enumerable)
  end

  def map(first..last//step, fun) do
    map_range(first, last, step, fun)
  end

  def map(enumerable, fun) do
    reduce(enumerable, [], R.map(fun)) |> :lists.reverse()
  end
  # ...
```

#### Практика создаём модуль Calendar
создадимо новый модуль Calendar который бы мог
- хранить события колендаря
- позволял добавлять новые события
- отображать события

Сразу выносим модуль Calendar внутрь MyCalendar.Model т.к. здесь будет кое-что
еще.
```elixir
defmodule MyCalendar.Model do
  defmodule Calendar do
  end
end
```

Сalendar - это будет структура . поэтому `defstruct`
с одним полем `items` - список событий календаря

```elixir
defmodule MyCalendar.Model do
  defmodule Calendar do
    defstruct [:items]
  end
end
```

добавляем описание типов
```elixir
defmodule MyCalendar.Model do
  defmodule Calendar do
    @type t() :: %__MODULE__{          # описание типа данных данной струкруты
            items: [CaneldarItem.t()]  # CaneldarItem - это будущий протокол.
          }
    @enforce_keys [:items]
    defstruct [:items]

  end
end
```
Чуть позже напишем протокол CalendarItem и компилятор сам, автоматически создаст
нам тип CalendarItem.t()

Мы здесь вводим Протокол CalendarItem для того чтобы можно было абстрагироваться
от всех наших конкретных реализаций на разных структурах данных (кортежи, мапы,
структуры) EventTuple, EventMap, EventStruct, EventTypedStruct и т.д.

создаём функцию добавления события
```elixir
    #              arg1          arg2                 return value
    @spec add_item(Calendar.t(), CalendarItem.t()) :: Calendar.t()
    def add_item(calendar, item) do
      items = [item | calendar.items]
      %Calendar{calendar | items: items} # Map.put(calendar, KEY, VALUE)
    end
```

получаем такой код, и проверяем через mix compile есть ли ошибки компиляции
```elixir
defmodule MyCalendar.Model do
  defmodule Calendar do
    @type t() :: %__MODULE__{
            items: [CaneldarItem.t()]
          }
    @enforce_keys [:items]
    defstruct [:items]

    @spec add_item(Calendar.t(), CalendarItem.t()) :: Calendar.t()
    def add_item(calendar, item) do
      items = [item | calendar.items]
      %Calendar{calendar | items: items}
    end
  end
end
```

создаём sample_calendar
```elixir
defmodule MyCalendar do
  # ... старый код без изменений

  def sample_calendar() do
    alias MyCalendar.Model.Calendar

    %Calendar{items: []}
  end
end
```

```sh
iex -S mix
```
```elixir
iex> calendar = MyCalendar.sample_calendar()
%MyCalendar.Model.Calendar{items: []}
```

```elixir
  def sample_calendar() do
    alias MyCalendar.Model.Calendar

    %Calendar{items: []}
    |> Calendar.add_item(sample_event_map())     # +++
  end
```

```elixir
iex> recompile
Compiling 1 file (.ex)
Generated my_calendar app
:ok

# теперь календарь имеет одно событие, реализованное на словарях(Map)
iex> calendar = MyCalendar.sample_calendar()
%MyCalendar.Model.Calendar{
  items: [
    %{
      time: ~U[2025-04-09 15:00:00Z],
      title: "Weekly Team Meeting",
      place: %{office: "Office #1", room: "#Room 42"},
      participants: [
        %{name: "Bob", role: :project_manager},
        %{name: "Petya", role: :developer},
        %{name: "Kate", role: :qa},
        %{name: "Helen", role: :devops}
      ],
      agenda: [
        %{description: "candidat for developer position", title: "Inteview"},
        %{description: "disscuss main goals", title: "Direction"},
        %{description: "what to buy", title: "Cookies"}
      ]
    }
  ]
}
```


## первый подход к протоколу
чтобы просто положить новый элемент (Item) в список протокол не нужен.
но вот чтобы уже просто отобразить данные(show) протокол уже нужен


```elixir

defmodule MyCalendar.Model do
  defmodule Calendar do
    @type t() :: %__MODULE__{
            items: [CaneldarItem.t()]
          }
    @enforce_keys [:items]
    defstruct [:items]

    @spec add_item(Calendar.t(), CalendarItem.t()) :: Calendar.t()
    def add_item(calendar, item) do
      items = [item | calendar.items]
      %Calendar{calendar | items: items}
    end

    # здесь нужно будет пройтись по каждому событию внутри календаря и
    # сформировать для него текстовое представление
    @spec show(Calendar.t()) :: String.t()
    def show(calendar) do
      # ... нужен протокол идём писать CalendarItem
    end
  end

  # описываем свой собственный протокол
  defprotocol CalendarItem do
    @spec get_title(CalendarItem.t()) :: String.t()
    def get_title(event)

    @spec get_time(CalendarItem.t()) :: DateTime.t()
    def get_time(event)
  end
end
```

```elixir
defmodule MyCalendar.Model do
  alias MyCalendar.Model.CalendarItem     # для CalendarItem.t() в коде ниже

  defmodule Calendar do
    @type t() :: %__MODULE__{
            items: [CaneldarItem.t()]
          }
    @enforce_keys [:items]
    defstruct [:items]

    @spec add_item(Calendar.t(), CalendarItem.t()) :: Calendar.t()
    def add_item(calendar, item) do
      items = [item | calendar.items]
      %Calendar{calendar | items: items}
    end

    @spec show(Calendar.t()) :: String.t() # отображение событий в виде строки
    def show(calendar) do
      Enum.map(
        calendar.items,
        fn item ->
          title = CalendarItem.get_title(item)
          time = CalendarItem.get_time(item) |> DateTime.to_iso8601()
          "#{title} at #{time}"
        end)
      |> Enum.join("\n")
    end
  end

  defprotocol CalendarItem do
    @spec get_title(CalendarItem.t()) :: String.t()
    def get_title(event)

    @spec get_time(CalendarItem.t()) :: DateTime.t()
    def get_time(event)
  end
end
```


проверям в живую можно ли напрямую подставить время в строку
```elixir
iex(5)> DateTime.utc_now
~U[2025-04-10 08:43:10.672511Z]

iex(6)> now = DateTime.utc_now
~U[2025-04-10 08:43:18.320958Z]

iex(7)> "#{now}"
"2025-04-10 08:43:18.320958Z"

iex(8)> now |> DateTime.to_iso8601
"2025-04-10T08:43:18.320958Z"
```

```elixir
iex> recompile
iex> calendar = MyCalendar.sample_calendar()
%MyCalendar.Model.Calendar{
  items: [
    %{...}
  ]
}
iex> alias MyCalendar.Model.Calendar
MyCalendar.Model.Calendar

iex> Calendar.show(calendar)
** (Protocol.UndefinedError) protocol MyCalendar.Model.CalendarItem not implemented for type Map. There are no implementations for this protocol.

Got value:

    %{
      time: ~U[2025-04-09 15:00:00Z],
      title: "Weekly Team Meeting",
      # ...
    }

    lib/model/calendar.ex:30: MyCalendar.Model.CalendarItem.impl_for!/1
    (my_calendar 0.1.0) lib/model/calendar.ex:22: anonymous fn/1 in MyCalendar.Model.Calendar.show/1
    (elixir 1.18.3) lib/enum.ex:1714: Enum."-map/2-lists^map/1-1-"/2
    (my_calendar 0.1.0) lib/model/calendar.ex:19: MyCalendar.Model.Calendar.show/1
    iex:12: (file)
```
это ошибка говорит о том, что наше MyCalendar.Model.EventMap не имеет реализации
нашего протокола CalendarItem


#### Добавляем реализацию протокола CalendarItem

```elixir
defmodule MyCalendar.Model do
  alias MyCalendar.Model.CalendarItem

  defmodule Calendar do
    # ...
  end

  defprotocol CalendarItem do
    @spec get_title(CalendarItem.t()) :: String.t()
    def get_title(event)

    @spec get_time(CalendarItem.t()) :: DateTime.t()
    def get_time(event)
  end


  defimpl CalendarItem, for: Map do   # +++ добавляем дефолтную реализацию для Map
  #       1                  2
  end
end
```

- 1. имя протокола который будем реализовывать для
- 2. имя типа данных, структуры для которой эта реализация протокола

```elixir
  defimpl CalendarItem, for: Map do
    @spec get_title(CalendarItem.t()) :: String.t()
    def get_title(event), do: Map.get(event, :title, "Unknow")
    #                   ^^^^^^ конкретная реализация - вытаскиваем значение из Map

    @spec get_time(CalendarItem.t()) :: DateTime.t()
    def get_time(event), do: Map.get(event, :time)
    #                   ^^^^^^^^^^^^^^^^^^^^^^^^^
  end
```

проверяем работу реализованного протокола CalendarItem для Map
```elixir
iex> recompile
Compiling 1 file (.ex)
Generated my_calendar app
:ok

iex> Calendar.show(calendar)
"Weekly Team Meeting at 2025-04-09T15:00:00Z"
```
работает - выводит текстовое представление для события календаря

добавляем еще 2 события реализованные на других структурах данных
```elixir
  def sample_calendar() do
    alias MyCalendar.Model.Calendar

    %Calendar{items: []}
    |> Calendar.add_item(sample_event_map())
    |> Calendar.add_item(sample_event_struct())
    |> Calendar.add_item(sample_event_typed_struct())
  end
```

```elixir
iex> recompile
Compiling 1 file (.ex)
Generated my_calendar app
:ok

iex> calendar = MyCalendar.sample_calendar()
%MyCalendar.Model.Calendar{
  items: [
    %MyCalendar.Model.EventTypedStruct.Event{
      title: "Weekly Team Meeting",
      time: ~U[2025-04-09 17:17:00Z],
      # ....
    },
    %MyCalendar.Model.EventStruct.Event{
      title: "Weekly Team Meeting",
      time: ~U[2025-04-09 17:17:00Z],
      # ....
    },
    %{
      time: ~U[2025-04-09 15:00:00Z],
      title: "Weekly Team Meeting",
      # ....
  ]
}

# т.к. для новых двух событий протокол еще не реализован снова получим ошибку
iex> Calendar.show(calendar)
** (Protocol.UndefinedError) protocol MyCalendar.Model.CalendarItem
not implemented for type MyCalendar.Model.EventTypedStruct.Event (a struct)
...
```


дописываем реализации для двух модулей:
```elixir
defmodule MyCalendar.Model do
  alias MyCalendar.Model.CalendarItem

  # ...

  defimpl CalendarItem, for: MyCalendar.Model.EventTypedStruct.Event do
    @spec get_title(CalendarItem.t()) :: String.t()
    def get_title(event), do: event.title

    @spec get_time(CalendarItem.t()) :: DateTime.t()
    def get_time(event), do: event.time
  end

  defimpl CalendarItem, for: MyCalendar.Model.EventStruct.Event do
    @spec get_title(CalendarItem.t()) :: String.t()
    def get_title(event), do: event.title

    @spec get_time(CalendarItem.t()) :: DateTime.t()
    def get_time(event), do: event.time
  end
```

```elixir
iex> Calendar.show(calendar) |> IO.puts()
Weekly Team Meeting at 2025-04-09T17:17:00Z
Weekly Team Meeting at 2025-04-09T17:17:00Z
Weekly Team Meeting at 2025-04-09T15:00:00Z
:ok
```

немного подправим даты и названия событий в sample_ функциях:

```elixir
# recompile
iex> calendar = MyCalendar.sample_calendar()
...
iex> Calendar.show(calendar) |> IO.puts()
Weekly Team Meeting #2 at 2025-04-09T18:18:00Z
Sprint Review at 2025-04-09T17:17:00Z
Interview at 2025-04-09T15:00:00Z
:ok
```

Обычно для модулей-структур реализацию протоколов принято указывать внутри
самого модуля а не где-то еще.


```elixir
defmodule MyCalendar.Model do
  alias MyCalendar.Model.CalendarItem

  # ...

  # то есть вот эти реализации нужно перенести в соотв. модули их структур
  defimpl CalendarItem, for: MyCalendar.Model.EventStruct.Event do
    # ...
  end
  defimpl CalendarItem, for: MyCalendar.Model.EventStruct.Event do
    # ...
  end
```

```elixir
defmodule MyCalendar.Model.EventTypedStruct do
  # ...
  defmodule Event do
    alias MyCalendar.Model.CalendarItem    # (+++)

    @type t() :: %__MODULE__{...}

    @enforce_keys [:title, :place, :time]

    defstruct [ ... ]

    @spec add_participant(Event.t(), Participant.t() | atom()) :: Event.t()
    def add_participant(event, _participant) do
      event
    end

    # defimpl CalendarItem, for: MyCalendar.Model.EventTypedStruct.Event do
    defimpl CalendarItem do # ^^^ (1)
      @spec get_title(CalendarItem.t()) :: String.t()
      def get_title(event), do: event.title

      @spec get_time(CalendarItem.t()) :: DateTime.t()
      def get_time(event), do: event.time
    end
  end
end
```

- 1. когда реализация протокола описывается в самом модуле который реализует
этот протокол не нужно указывать `, for: ModuleName`


```elixir
defmodule MyCalendar.Model.EventStruct do
  # ...
  defmodule Event do
    alias MyCalendar.Model.CalendarItem

    @enforce_keys [:title, :place, :time]

    defstruct [... ]

    def add_participant(...) do
      ...
    end

    # aka update by name
    def replace_participant(...) do
      ...
    end

    # defimpl CalendarItem, for: MyCalendar.Model.EventStruct.Event do
    defimpl CalendarItem do #^^^^^^^^^ так же, здесь это больше не нужно
      @spec get_title(CalendarItem.t()) :: String.t()
      def get_title(event), do: event.title

      @spec get_time(CalendarItem.t()) :: DateTime.t()
      def get_time(event), do: event.time
    end
  end
end
```

код готово проеряем копиляцию

```sh
mix compile
Compiling 3 files (.ex)
Generated my_calendar app
```

статичесикй анализ кода
```sh
mix dialyzer
...
Starting Dialyzer
[ check_plt: false, ... warnings: [:unknown] ]
Total errors: 1, Skipped: 0, Unnecessary Skips: 0
done in 0m2.66s
lib/model/calendar.ex:6:33:unknown_type
Unknown type: CaneldarItem.t/0.
________________________________________________________________________________
done (warnings were emitted)
Halting VM with exit status 2
```

упс.. опечатка, исправляю и теперь ошибок нет

```sh
Total errors: 0, Skipped: 0, Unnecessary Skips: 0
done in 0m2.77s
done (passed successfully)
```

Запускаем проект в консоли
```sh
iex -S mix
```

проверяем

```elixir
iex(1)> calendar = MyCalendar.sample_calendar()
%MyCalendar.Model.Calendar{
  items: [
    %MyCalendar.Model.EventTypedStruct.Event{
      title: "Weekly Team Meeting #2",
      time: ~U[2025-04-09 18:18:00Z],
      # ...
    },
    %MyCalendar.Model.EventStruct.Event{
      title: "Sprint Review",
      time: ~U[2025-04-09 17:17:00Z],
      # ...
    },
    %{
      time: ~U[2025-04-09 15:00:00Z],
      title: "Interview",
      # ...
    }
  ]
}

iex(2)> alias MyCalendar.Model.Calendar
MyCalendar.Model.Calendar

iex(3)> Calendar.show(calendar) |> IO.puts()
Weekly Team Meeting #2 at 2025-04-09T18:18:00Z
Sprint Review at 2025-04-09T17:17:00Z
Interview at 2025-04-09T15:00:00Z
:ok
```



реализуем протокол для кортежа
```elixir
  def sample_calendar() do
    alias MyCalendar.Model.Calendar

    %Calendar{items: []}
    |> Calendar.add_item(sample_event_map())
    |> Calendar.add_item(sample_event_struct())
    |> Calendar.add_item(sample_event_typed_struct())
    |> Calendar.add_item(sample_event_tuple())           # (+)
  end
```

```elixir
defmodule MyCalendar.Model do
  alias MyCalendar.Model.CalendarItem

  defmodule Calendar do
    # ...
  end

  defprotocol CalendarItem do
    # ...
  end


  defimpl CalendarItem, for: Map do
    # ...
  end

  defimpl CalendarItem, for: Tuple do                       # <<<<
    @spec get_title(CalendarItem.t()) :: String.t()
    def get_title({:event, title, _, _, _, _}), do: title    # реализация

    @spec get_time(CalendarItem.t()) :: DateTime.t()
    def get_time({:event, _, _, time, _, _}), do: time
  end
end
```

```elixir
iex recompile
iex> calendar = ...

iex Calendar.show(calendar) |> IO.puts()
Weekly Team Meeting at 2025-04-09T15:00:00Z
Weekly Team Meeting #2 at 2025-04-09T18:18:00Z
Sprint Review at 2025-04-09T17:17:00Z
Interview at 2025-04-09T15:00:00Z
:ok
```

таким образом наш календарь умеет работать с событиями реализованными на
разных структурах данных, от кортежей, и словарей до структур и типизировнных
структур.


