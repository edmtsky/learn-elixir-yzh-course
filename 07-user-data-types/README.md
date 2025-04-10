# Урок 7 Пользовательские типы данных

- 07.01 Создание проекта и моделирование предметной области
  - Начало моделирование предметной области
  - Моделирование используя кортежи и списки.
- 07.02 Использование Map
- 07.03 Использование Struct
- 07.04 Struct с указанием типов (Typed Struct)
- 07.05 Алгебраические типы данных
- 07.06 Протокол
- 07.07 Record
- 07.08 Что такое функциональное программирование?


## 07.01 Создание проекта и моделирование предметной области
### Создание проекта

Выходим на новый уровень, от одиночных разрозненных скриптов на уровень проекта
где нужно разделять код на множество взаимосвязанных модулей, способных
взаимодействовать друг с другом. подключать внешние зависимости.

Сначала создадим проект, а уже далее будем моделировать предметную область для
некой выбранной области.

Создать проект можно используя консольную утилиту `mix` - это менеджер для языка
Elixir, умеющий в том числе создавать новые проекты.

Первой предметной областью будет календарь отслюда название проекта my_calendar

```sh
mix new my_calendar

* creating README.md
* creating .formatter.exs
* creating .gitignore
* creating mix.exs
* creating lib
* creating lib/my_calendar.ex
* creating test
* creating test/test_helper.exs
* creating test/my_calendar_test.exs

Your Mix project was created successfully.
You can use "mix" to compile it, test it, and more:

    cd my_calendar
    mix test

Run "mix help" for more commands.
```

Смотрим что было сгенерировано в новом созданном проекте
```sh
tree
.
├── lib
│   └── my_calendar.ex
├── mix.exs
├── README.md
└── test
    ├── my_calendar_test.exs
    └── test_helper.exs
```

- mix.exs - конфигурационный файл описывающий данный проект,
  используется утилитой mix
- lib/ - каталог для наших исходных кодов
- lib/my_calendar.ex - заготовка точки входа в наш проект

./mix.exs
```elixir
defmodule MyCalendar.MixProject do
  use Mix.Project

  def project do
    [
      app: :my_calendar,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
```

как видим конфигурация проекта mix.exs - это чисто эликсировский код с модулем
MyCalendar.MixProject. Но это именно конфиг для утилиты `mix`, а не исходник.

mix.exs по умолчанию состоит из 3х блоков
- project  - мето данные о проекте, название, версия, тип окружения
- application
- deps

каждый такой блок представлен через структуру данных Keyword-List
Keyword-List - это список элементы которого являются кортежи из 2х элементов
пар - ключ-значение. Значение может быть любым эликсировским значением, а не
только просто атомом или строкой.

Синтаксический сахар для описания пар Keyword-List-а
```elixir
[ app: :my_calendar, ]
```
без синтаксического сахара:
```elixir
[ {:app, :my_calendar}, ]
[ {:dep_from_hexpm, "~> 0.3.0"}, ]
```
в блоке deps элементы задаются без синтаксического сахара т.к. это могут быть
не просто кортежи из пар как в project.


## README.md
Это краткая выжимка знаний о проекте
- название проекта, описание,
- описание как запустить проект:
  - как собрать и развернуть(deploy)
  - как накатить миграции и внешние зависимости и проч.

этот файл своего рода визитная карточка проекта, и первое место куда должен
смотреть новый разработчик пришедший в команду для знакомство с проектом.
Поэтому крайне рекомендуется всего поддерживать данный файл в актуальном
стостоянии.

lib/my_calendar.ex
```elixir
defmodule MyCalendar do
  @moduledoc """
  Documentation for `MyCalendar`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> MyCalendar.hello()
      :world

  """
  def hello do
    :world
  end
end
```

То есть теперь у нас есть заготовка проекта, который можно собрать и запустить

часто проекты имеют внешние зависимости, которые до начала работы нужно подтянуть
из удалённых или локальных хранилищь:

```sh
mix deps.get
All dependencies are up to date
```

Скомпилировать исходный код проекта
```sh
mix compile
```

```sh
.
├── _build
│   └── dev                                     # имя окружения (dev|prod|test)
│       └── lib
│           └── my_calendar
│               ├── consolidated
│               │   ├── Elixir.Collectable.beam
│               │   ├── Elixir.Enumerable.beam
│               │   ├── Elixir.IEx.Info.beam
│               │   ├── Elixir.Inspect.beam
│               │   ├── Elixir.JSON.Encoder.beam
│               │   ├── Elixir.List.Chars.beam
│               │   └── Elixir.String.Chars.beam
│               └── ebin
│                   ├── Elixir.MyCalendar.beam
│                   └── my_calendar.app
├── lib
│   └── my_calendar.ex
├── mix.exs
├── README.md
└── test
    ├── my_calendar_test.exs
    └── test_helper.exs
```

Как видно в _build/dev/lib лежат файлы с скомпилированным байткодом (*.beam)


### Начало моделирование предметной области

#### Сущность Встреча/Совещание

Начинаем продумывать сущность "Встреча(Совещание)"

Встреча (митинг, совещание):
  - место (где?)
  - время (когда?)
  - участники (кто?)
  - агенда ( о чём?)

Выходит нам нужна одна родительская сущность "Встреча" состоящая из еще 4х
дочерникх сущностей. Более формально:
нас есть предметная область(domain) состоящая из 5 сущностей, которые нужно
как-то описать средствами нашего целового языка программирования.

Пример того как могут выглядеть сущности предметной области:

- место: Офис №1, 7й этаж, переговорка №1
- время: 5 июля 2024 15:00 (можно использовать встроенный в Elixir тип данных)
- участники: Вася, Петя, Лена
- агенда: собеседование кандидата, обсуждение самых важных дел


Моделировать сущности предметной области можно разными способами
в рамках этого моделирования познакомимся как применять разные структуры данных
  языка Elixir, для представления обьектов предметной области.

способы моделирования предметной области на основе:
- кортежей и списков
- словарей(Map)
- struct(структура)
- typed struc(типизированная структура)

По ходу дела будем
- создавать сущности,
- комбинировать сущности друг с другом
- обновлять представление сущностей
- и всякие специфичные вещи для каждой из структур данных


#### Моделирование используя кортежи и списки.

- это достаточно архаичный способ.

Опытные разработчики программирующие на Эрланге в 2008(когда еще не было Эликсира)
могут вспомнить что тогда в языке еще даже словарей(Map) не было.
Map завезли в Erlang v17 это примерно 2014 год. Другими словами в Эрланге
который начали разрабатывать ~1985года, и начали использовать с нач ~1990хх
То есть больше 20 лет Эрланг жил без Map, и похожие вещи описывали используя
кортежи и списки. (В начале это курса мы именно так и делали, когда возились
с кортежами юзеров их сортировкой и обработкой, потипу {:user, ...}

В общем описывание сущностей через кортежи способ архаичный, и в реальных
проектах почти не используется, кроме как для описание каких-то совсем простых
вещей, потипу даты-времени.

То есть в современном проекте описывать такую доменную сущность как "встреча"
через кортежи не следует, но в целях изучения языка. мы начнём именно с такого
подхода.

каталог в котором будет описывать подули для моделей предметной области.
```sh
mkdir lib/model/
```
сами же экземпляры сущностей будут в ./lib/my_calendar.ex

Создаём модуль EventTuple, указывая полное имя похожее на название пакета.
- MyCalendar - название проекта
- Model - от имени каталога model
- EventTuple - само название модуля

Внутри создаём подмодули для каждой сущности предметной области:
- Place - место встречи
- Participant - участник
- Topiс - конкретная тема, как часть всей встречи(agenda)
- Event - под саму встречу
- дата-время - возмём эликсировкий тип


lib/model/event_tuple.ex
```elixir
defmodule MyCalendar.Model.EventTuple do
  defmodule Place do
    def new(office, room) do
      {:place, office, room}
    end
  end

  # datatime

  defmodule Participant do
    def new(name, role) do
      {:participant, name, role}
    end
  end

  defmodule Topic do
    def new(title, description) do
      {:topic, title, descriptio}
    end
  end

  defmodule Event do
    def new(title, place, time, participants, agenta) do
      {:event, title, place, time, participants, agenda}
    end
  end
end
```

Пример использования данного модуля для создания сущностей предметной области

./lib/my_calendar.ex
```elixir
defmodule MyCalendar do
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

end
```

Для удобства можно создавать алиас(псевдоним) для длинных названий типов:
```elixir
 alias MyCalendar.Model.EventTuple, as: T
```
причем это можно делать не только в начале модуля, но и внутри конкретной функции
так чтобы не вызывать конфликты на уровне других функций. Это будет особенно
удобно т.к. мы будем моделировать одни и те же модели на основе разных типов
данных, используя одни и те же имена.

компилируем весь проект, из корневой директории проекта (где лежит mix.exs)
```sh
mix compile
Compiling 2 files (.ex)
Generated my_calendar app
```

Взаимодействие с скомпилированным кодом проекта через iex-shell
```sh
iex -S mix
```
- компилирует весь проект
- подгружает в iex консоль все модули проекта
- делает их доступными из консоли

вот пример того как можно вызвать функцию создания обьекта "встреча" прямо
из консоли и посмотреть на результат её работы
```elixir
iex> MyCalendar.sample_event_tuple()
{:event, "Weekly Team Meeting", {:place, "Office #1", "#Room 42"},
 ~U[2025-04-09 15:00:00Z],
 [
   {:participant, "Bob", :project_manager},
   {:participant, "Petya", :developer},
   {:participant, "Kate", :qa},
   {:participant, "Helen", :devops}
 ],
 [
   {:topic, "Inteview", "candidat for developer position"},
   {:topic, "Direction", "disscuss main goals"},
   {:topic, "Cookies", "what to buy"}
 ]}
```



## 07.02 Использование Map

Продолжаем в рамках созданного проекта, и в рамках той же предметной области
"события внутри календаря". Смоделируем тоже самое на основе Словарей(Map)

```elixir
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
  end
end
```
использование
```elixir
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
```

проверяем
```sh
iex -S mix

```
```elixir
iex> MyCalendar.sample_event_map()
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
```

попробуем это сделать "руками" через консоль:

сначало создаю участника
```elixir
iex> alias MyCalendar.Model.EventMap, as: M
MyCalendar.Model.EventMap

iex> john = M.Participant.new("John", :developer)
%{name: "John", role: :developer}

iex> event = MyCalendar.sample_event_map()
%{...}

iex> ps = event.participants
[
  %{name: "Bob", role: :project_manager},
  %{name: "Petya", role: :developer},
  %{name: "Kate", role: :qa},
  %{name: "Helen", role: :devops}
]

# добавляем нового участника в голову списка
iex> ps = [john | ps]
[
  %{name: "John", role: :developer},
  %{name: "Bob", role: :project_manager},
  %{name: "Petya", role: :developer},
  %{name: "Kate", role: :qa},
  %{name: "Helen", role: :devops}
]

# вставка обновлённого списка в Обьект event
iex> event = %{event | participants: ps}
%{
  time: ~U[2025-04-09 15:00:00Z],
  title: "Weekly Team Meeting",
  place: %{office: "Office #1", room: "#Room 42"},
  participants: [
    %{name: "John", role: :developer},            # <<< new Participant
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
```

#### Map.update как тоже самое можно сделать проще.

Смотрим справку по Map.update чтобы понять как с этим работать
```elixir
iex> h Map.update
                       def update(map, key, default, fun)

  @spec update(map(), key(), default :: value(), (existing_value :: value() ->
                                                    new_value :: value())) ::
          map()

Updates the key in map with the given function.

If key is present in map then the existing value is passed to fun and its
result is used as the updated value of key. If key is not present in map,
default is inserted as the value of key. The default value will not be passed
through the update function.

## Examples

    iex> Map.update(%{a: 1}, :a, 13, fn existing_value -> existing_value * 2 end)
    %{a: 2}
    iex> Map.update(%{a: 1}, :b, 11, fn existing_value -> existing_value * 2 end)
    %{a: 1, b: 11}
```

```elixir
iex> alice = M.Participant.new("Alice", :qa)
%{name: "Alice", role: :qa}
```

```elixir
#                       map    key         def-val  updater-func
iex> event = Map.update(event, :participants, [], fn ps -> [alice | ps] end)
#                                             oldvalue^    [head | tail]
#                                                          ^new_value
%{
  time: ~U[2025-04-09 15:00:00Z],
  title: "Weekly Team Meeting",
  place: %{office: "Office #1", room: "#Room 42"},
  participants: [
    %{name: "Alice", role: :qa},                       ## <<<
    %{name: "John", role: :developer},
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
```

"сдвинуть" дату-время на 1 час
```elixir
iex(11)> event = Map.update(event, :time, nil, fn dt -> DateTime.add(dt, 1, :hour) end)
%{
  time: ~U[2025-04-09 16:00:00Z],
  title: "Weekly Team Meeting",
  place: %{office: "Office #1", room: "#Room 42"},
  participants: [
    %{name: "Alice", role: :qa},
    %{name: "John", role: :developer},
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
```


добавление в модель функции добавления нового участника
```elixir
defmodule MyCalendar.Model.EventMap do
  # .. без измнений

  defmodule Event do
    def new(title, place, time, participants, agenda) do
      # без измнений
    end

    def add_participant(event, participant) do
      Map.update(event, :participants, [], fn participants ->
        [participant | participants]
      end)
    end
  end
end
```
перекомпилируем
```elixir
iex> recompile
Compiling 2 files (.ex)
Generated my_calendar app
:ok
```

еще раз добавляю Alice уже через функцию модуля Event
```elixir
iex> M.Event.add_participant(event, alice)
%{
  time: ~U[2025-04-09 16:00:00Z],
  title: "Weekly Team Meeting",
  place: %{office: "Office #1", room: "#Room 42"},
  participants: [
    %{name: "Alice", role: :qa},                     # <<
    %{name: "Alice", role: :qa},
    %{name: "John", role: :developer},
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
```

Вообще в хорошей реализации функции Event.add_participant нужна защита от
дублирования, с запретом на добавление дублирующихся данных.

добавление функции add_participant можно является расширением API нашей модели.


#### обновление вложенных значений
(примеры более продвинутой работы со (развесистыми)словарями(Map)
рекомендуется ознакомится с модулем Access - этот модуль про навигацию по
вложенным путям, работает не только с Map но и с Keyword-List и с tuple(кортежи)


ф-я Map.update позволяет исправлять значения только на корневом уровне.
через него например нельзя исправить название одной из целей в agenda->[0].title

можно конечно через связку функций Map.update сделать подобное:
(пример для 2го уровня вложенности - меняем название комнаты для встречи)
```elixir
iex(15)> event= %{event | place: %{event.place | room: "Room 43"}}
%{
  time: ~U[2025-04-09 16:00:00Z],
  title: "Weekly Team Meeting",
  place: %{office: "Office #1", room: "Room 43"},
  participants: [ ... ], #                  ^^
  agenda: [ ... ]
}
```
но это не удобно и громоздко


Работа с вложенными структурами данных
в словарях есть такой набор функций(макросов) как
- `get_in` (F), `put_in` (F/M), `update_in` (F)
все они из модуля Kernel, т.е. их можно использовать прямо так без имени модуля.

##### get_in - извлечение данных по вложенному пути
Позволяет очень гибко описывать путь внутри древовидной структуры данных,
и получать значения по описанному пути.

```elixir
iex> get_in(event, [:place, :room])
"Room 43"

# тоже самое, напрямую без функций
iex> event.place.room
"Room 43"
```
Функция get_in позволяет
- генерить нужный путь динамически.
- корректно обрабатывать nil (чез обычную dot-нотацию было бы исключение)

указывать нужный путь не только внутри словарей, но еще и в кортежах, списках
и прочем через get_in можно не только через простые значения но и через передачу
функций, которые умеют обрабатывать структуру данных по которой нужно пройти.
Access - модуль содержащий функции для использования в get_in.

> Access.all() - как часть "пути" для доступа ко всем элементам

Пример использования модуля Access для получения заголовков Agenda нашего event
```elixir
iex> get_in(event, [:agenda, Access.all(), :title])
["Inteview", "Direction", "Cookies"]

# получение имён всех участников
iex> get_in(event, [:participants, Access.all(), :name])
["Alice", "John", "Bob", "Petya", "Kate", "Helen"]

iex> get_in(event, [:participants, Access.all()])
[
  %{name: "Alice", role: :qa},
  %{name: "John", role: :developer},
  %{name: "Bob", role: :project_manager},
  %{name: "Petya", role: :developer},
  %{name: "Kate", role: :qa},
  %{name: "Helen", role: :devops}
]
```

> Access.at(N) доступ к элементу нужного индеса

```elixir
iex> get_in(event, [:participants, Access.at(0), :name])
"Alice"

iex> get_in(event, [:participants, Access.at(2), :name])
"Bob"

iex> get_in(event, [:participants, Access.at(5), :name])
"Helen"

# при выходе за границы просто вернёт nil
iex> get_in(event, [:participants, Access.at(50), :name])
nil

# когда нужно чтобы кинуло исключение - Access.at!(N)
iex(26)> get_in(event, [:participants, Access.at!(50), :name])
** (Enum.OutOfBoundsError) out of bounds error
    (elixir 1.18.3) lib/access.ex:822: Access.at!/4
    iex:26: (file)
```

Есть даже функция для фильтрации элементов на основе заданной функции-предиката
```elixir
iex(26)> get_in(event, [:participants, Access.filter(fn p->p.role == :developer end), :name])
["John", "Petya"]
```


#### пример доступа к данных где есть два вложенных списка

```elixir
iex> calendar = %{events: [event, event, event]}
iex> get_in(calendar, [:events, Access.all(), :agenda, Access.all(), :description])
[
  ["candidat for developer position", "disscuss main goals", "what to buy"],
  ["candidat for developer position", "disscuss main goals", "what to buy"],
  ["candidat for developer position", "disscuss main goals", "what to buy"]
]
```


#### макрос и функция put_in обновление/замена данных по указанному пути

Извлекать данные не самая сложная здача. хотя конечно через get_in она становится
намного проще, иначе бы пришлось бы делать что-то вроде

calendar.events |> Enum.filter(...

macro: (2 аргумента)
```elixir
iex> put_in(event.place.room, "Room 44")
%{
  time: ~U[2025-04-09 16:00:00Z],
  title: "Weekly Team Meeting",
  place: %{office: "Office #1", room: "Room 44"},
  participants: [...],
  agenda: [...]
}
```

function: (3 аргумента)
```elixir
#           map    path
iex> put_in(event, [:place, :room], "Room 45")
%{
  time: ~U[2025-04-09 16:00:00Z],
  title: "Weekly Team Meeting",
  place: %{office: "Office #1", room: "Room 45"},
  participants: [...],
  agenda: [...]
}
```

в макросе указываем прям путь через точки: event.place.room
но чтобы это работало нужно чтобы все такие ключи были известны заранее, то есть
в макросе нельзя использовать модуль Access и формировать путь динамически, а
вот функция put_in/3 ползволяет это делать

пример - исправляем Alice c qa до dev
```elixir
iex> event
%{
  time: ~U[2025-04-09 16:00:00Z],
  title: "Weekly Team Meeting",
  place: %{office: "Office #1", room: "Room 43"},
  participants: [
    %{name: "Alice", role: :qa},                # << будем исправлять (index:0)
    %{name: "John", role: :developer},
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

iex> event = put_in(event, [:participants, Access.at(0), :role], :developer)
%{
  time: ~U[2025-04-09 16:00:00Z],
  title: "Weekly Team Meeting",
  place: %{office: "Office #1", room: "Room 43"},
  participants: [
    %{name: "Alice", role: :developer},            # fixed!
    %{name: "John", role: :developer},
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
```

> update_in делаем все заголовки Uppercase

```elixir
iex> event = update_in(event, [:agenda, Access.all(), :title], fn title -> String.upcase(title) end)

%{
  time: ~U[2025-04-09 16:00:00Z],
  title: "Weekly Team Meeting",
  place: %{office: "Office #1", room: "Room 43"},
  participants: [
    %{name: "Alice", role: :developer},
    %{name: "John", role: :developer},
    %{name: "Bob", role: :project_manager},
    %{name: "Petya", role: :developer},
    %{name: "Kate", role: :qa},
    %{name: "Helen", role: :devops}
  ],
  agenda: [
    %{description: "candidat for developer position", title: "INTEVIEW"},
    %{description: "disscuss main goals", title: "DIRECTION"},
    %{description: "what to buy", title: "COOKIES"}
  ]
}
```

Рекомендуется ознакомится с документацией по модулю Access.



## 07.03 Использование Struct

Моделируем модели предметной области календаря используя Struct

Struct - рабочая лошадка Эликсира и основное средство для моделирования
предметной области.

```sh
touch lib/model/event_struct.ex
```

```elixir
defmodule MyCalendar.Model.EventStruct do

  defmodule Place do
    #         ^(1)
    defstruct [:office, :room]
  end

end
```

- 1. это одновременно и имя модуля и имя структуры


```sh
iex -S mix
```
Обрати внимание перед именем структуры ставиться `%` а дальше через авто-
дополнение через таб (т.к. структура на весь проетк одна)
```elixir
iex()>  event = %MyCalendar.Model.EventStruct.Place{office: "Office #1", room: "Room #1"}
%MyCalendar.Model.EventStruct.Place{office: "Office #1", room: "Room #1"}
```

Внутри модуля может быть только одна структура, структура может быть только
внутри модуля. Другими словами структура(Struct) и модуля тесно связаны между
собой. И создаётся структура через макрос defstruct

алиас и создание через короткий алиас

```elixir
iex> alias MyCalendar.Model.EventStruct.Place
MyCalendar.Model.EventStruct.Place

iex> place = %Place{office: "Office #1", room: "Room #2"}
%MyCalendar.Model.EventStruct.Place{office: "Office #1", room: "Room #2"}
```

Для темы встречи добавим новый атрибут и зададим ему значение по умолчанию
```elixir
  defmodule Topic do
    defstruct [:title, :description, {:priority, :medium}]
  end
```

такой формат будет читаться легче:
```elixir
  defmodule Topic do
    defstruct [
      :title,
      :description,
      {:priority, :medium}
    ]
  end
```

```elixir
iex> alias MyCalendar.Model.EventStruct.Topic
MyCalendar.Model.EventStruct.Topic

iex> topic1 = %Topic{title: "Topit 1", description: "description", priority: :high}
%MyCalendar.Model.EventStruct.Topic{
  title: "Topit 1",
  description: "description",
  priority: :high
}

# значение по умолчанию
iex(42)> topic2 = %Topic{title: "Topit 2", description: "description"}
%MyCalendar.Model.EventStruct.Topic{
  title: "Topit 2",
  description: "description",
  priority: :medium
}

# если не указать значений - и знач. по умолч. не указано будет nil
iex(43)> topic3 = %Topic{}
%MyCalendar.Model.EventStruct.Topic{
  title: nil,
  description: nil,
  priority: :medium
}
```

#### @enforce keys - Делаем атрибуты стурктуры обязательными

```elixir
defmodule MyCalendar.Model.EventStruct do
  defmodule Place do
    defstruct [:office, :room]
  end

  defmodule Topic do
    @enforce_keys [:title]
    defstruct [
      :title,
      :description,
      {:priority, :medium}
    ]
  end
end
```

```elixir
iex> recompile

# пробуем еще раз создать сущность не указывая обязательное поле - ошибка
iex(45)> topic3 = %Topic{}
** (ArgumentError) the following keys must also be given when building struct MyCalendar.Model.EventStruct.Topic: [:title]
    expanding struct: MyCalendar.Model.EventStruct.Topic.__struct__/1
    iex:45: (file)
```
это исключение говорит о том, что поле :title в структуре обязательно и без
него нельзя создать экземпляр сущности

```elixir
iex(45)> topic4 = %Topic{title: "Topic 4"}
%MyCalendar.Model.EventStruct.Topic{
  title: "Topic 4",
  description: nil,                        # значение по умолчанию (nil)
  priority: :medium                        # указанное значение по умолчанию
}
```

Struct - это абстракция языка элексир, существующая только на этапе компиляции
и например нельзя указать "лишнее" поле.
```elixir
iex> topic4 = %Topic{title: "Topic 4", some: 42}
** (KeyError) key :some not found
    expanding struct: MyCalendar.Model.EventStruct.Topic.__struct__/1
    iex:46: (file)
```
но эти проверки действуют только на этапе компиляции, в runtime всё это на деле
представляет собой обычный Словарь(Map) с доп ключем `__struct__`: который
указывает на имя модуля, где эта структура опеределена
```elixir
iex(46)> topic4.__struct__
MyCalendar.Model.EventStruct.Topic
```

Способ как преобразовать структуру в словарь(Map)
```elixir
iex(47)> topic_as_map = Map.from_struct(topic4)
%{priority: :medium, description: nil, title: "Topic 4"}
```

исследуем значение в переменной topic4
```elixir

iex> i topic4
Term
  %MyCalendar.Model.EventStruct.Topic{title: "Topic 4", description: nil, priority: :medium}
Data type
  MyCalendar.Model.EventStruct.Topic          ## тип данных структуры
Description
  This is a struct. Structs are maps with a __struct__ key.
Reference modules
  MyCalendar.Model.EventStruct.Topic, Map
Implemented protocols
  IEx.Info, Inspect
```

Term - детальное описание значение в переменной topic4
Data type - что это За тип такой - структура и модуль где она определена


```elixir
iex> i topic_as_map
Term
  %{priority: :medium, description: nil, title: "Topic 4"}
Data type
  Map
Reference modules
  Map
Implemented protocols
  Collectable, Enumerable, IEx.Info, Inspect, JSON.Encoder
```
здесь же видем что значение это - Map(Словарь)


Дописываю остальные части модеменной модели события встречи

```elixir
defmodule MyCalendar.Model.EventStruct do
  defmodule Place do
    @enforce_keys [:office, :room]

    defstruct [:office, :room]
  end

  defmodule Participant do
    @enforce_keys [:name, :role]

    defstruct [:name, :role]
  end

  defmodule Topic do
    @enforce_keys [:title]

    defstruct [
      :title,
      :description,
      {:priority, :medium}
    ]
  end

  defmodule Event do
    @enforce_keys [:title, :place, :time]

    defstruct [
      :title,
      :place,
      :time,
      {:participants, []},
      {:agenda, []}
    ]
  end
end
```

lib/my_calendar.ex
```elixir
  def sample_event_stuct() do
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
```

Запускаю консоль с проектом
```sh
iex -S mix
```
```html
Erlang/OTP 26 [erts-14.2.1] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [jit:ns]

Compiling 4 files (.ex)
Generated my_calendar app
Interactive Elixir (1.18.3) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
```

создаю экземпляр сущности на основе функции
```elixir
iex> event = MyCalendar.sample_event_struct()
%MyCalendar.Model.EventStruct.Event{
  title: "Weekly Team Meeting",
  place: %MyCalendar.Model.EventStruct.Place{
    office: "Office #1",
    room: "#Room 42"
  },
  time: ~U[2025-04-09 17:17:00Z],
  participants: [
    %MyCalendar.Model.EventStruct.Participant{
      name: "Bob",
      role: :project_manager
    },
    %MyCalendar.Model.EventStruct.Participant{name: "Petya", role: :developer},
    %MyCalendar.Model.EventStruct.Participant{name: "Kate", role: :qa}
  ],
  agenda: [
    %MyCalendar.Model.EventStruct.Topic{
      title: "Interview",
      description: "candidat for developer position",
      priority: :medium
    },
    %MyCalendar.Model.EventStruct.Topic{
      title: "Direction",
      description: "disscuss main goals",
      priority: :medium
    }
  ]
}
```

#### get_in, put_in, update_in для Struct
Играемся с созданным экземплятор сущности досту к вложенному полю:

```elixir
iex(3)> event.place.room
"#Room 42"
```

Установка нового значения имени комнаты через статический путь(макрос put_in)
```elixir
iex> put_in(event.place.room, "Room 43")
%MyCalendar.Model.EventStruct.Event{
  title: "Weekly Team Meeting",
  place: %MyCalendar.Model.EventStruct.Place{
    office: "Office #1",
    room: "Room 43"
  },
  time: ~U[2025-04-09 17:17:00Z],
  participants: [
    %MyCalendar.Model.EventStruct.Participant{
      name: "Bob",
      role: :project_manager
    },
    %MyCalendar.Model.EventStruct.Participant{name: "Petya", role: :developer},
    %MyCalendar.Model.EventStruct.Participant{name: "Kate", role: :qa}
  ],
  agenda: [
    %MyCalendar.Model.EventStruct.Topic{
      title: "Interview",
      description: "candidat for developer position",
      priority: :medium
    },
    %MyCalendar.Model.EventStruct.Topic{
      title: "Direction",
      description: "disscuss main goals",
      priority: :medium
    }
  ]
}
```

Установка значений динамически через функцию

```elixir
iex> get_in(event, [:place, :room])
** (UndefinedFunctionError) function MyCalendar.Model.EventStruct.Event.fetch/2 is undefined (MyCalendar.Model.EventStruct.Event does not implement the Access behaviour

You can use the "struct.field" syntax to access struct fields. You can also use Access.key!/1 to access struct fields dynamically inside get_in/put_in/update_in)
    (my_calendar 0.1.0) MyCalendar.Model.EventStruct.Event.fetch(%MyCalendar.Model.EventStruct.Event{title: "Weekly Team Meeting", place: %MyCalendar.Model.EventStruct.Place{office: "Office #1", room: "#Room 42"}, time: ~U[2025-04-09 17:17:00Z], participants: [%MyCalendar.Model.EventStruct.Participant{name: "Bob", role: :project_manager}, %MyCalendar.Model.EventStruct.Participant{name: "Petya", role: :developer}, %MyCalendar.Model.EventStruct.Participant{name: "Kate", role: :qa}], agenda: [%MyCalendar.Model.EventStruct.Topic{title: "Interview", description: "candidat for developer position", priority: :medium}, %MyCalendar.Model.EventStruct.Topic{title: "Direction", description: "disscuss main goals", priority: :medium}]}, :place)
    (elixir 1.18.3) lib/access.ex:322: Access.get/3
    (elixir 1.18.3) lib/kernel.ex:2832: Kernel.get_in/2
    iex:5: (file)
```

Эта ошибка говорит о том, что наш модуль ..EventStruct.Event не реализует некий
Access behaviour, поэтому такой динамический вызов get_in не работает

```elixir
iex> put_in(event, [:place, :room], "Room 43")
** (UndefinedFunctionError) function MyCalendar.Model.EventStruct.Event.get_and_update/3 is undefined (MyCalendar.Model.EventStruct.Event does not implement the Access behaviour
```
так же ошибка и для функции put_in.
Это ограничение на которое разработчки эликсир пошли создательно.
Макросы проверяются(указанные пути) на этапе компиляции поэтому через них
разрешается доступ к полям структуры, в вот функции с динамическими путями
работают в рантайме и не проверяются на этапе компиляции, поэтому и кидается
такая ошибка.
Проще говоря для Struct макросы get_in/put_in работают, а тех же функций нет.
Если реализовать `Access` `behaviour` и необходимые для него функций
внутри нашей структуры то это будет работать так как как с Map.
Просто из коробки для Map эти функции уже реализованы и работает по умолчанию
не требуя никаких доп. действий.


Но для того чтобы реализовать эти нужные функции для доступа к полям структуры
через динамические пути, нужно понять что такое Behaviour.

Вообще в Эликсир есть такие похожие друг на друга вещи как Behaviour и Protocol.
Это аналог interface в Java и trait в Rust. По простому говоря это про соглашение
о том, что модуль который претендует на то что реализует некий Behaviour обязан
реализован заранее заданный набор функций, которое этот Behaviour в себе описывает
чтобы зная тольк то, что данный модуль реализует этот конкретный Behaviour можно
было быть уверемнным что у точно него есть известные и нужные для работы функции.

#### Зачем два Behaviour и Protocol и чем они отличаются?

- Behaviour - это понятие унаследованное из Erlang
  то есть в элексир он достался "по наследству"
- Protocol - это уже нововведение разработчиков Elixir.
  (Им не понравился уже имеющийся Behaviour И они решили сделать более удобную
  штуку назвав её Protocol-ом)

Таким образом в Эликси есть две вещи делающих примерно одно и тоже, но по-разному

(Если есть косяки языка на уровне исключений. там та же история, разработчики
эликсир решили улучить имеющиеся исключения и добавили свои поверх тех которые
уже имелись в Эрланге.)


## Behaviour
эта штука состоит из двух частей:

Behaviour:
  - Behaviour module  (module Access)
  - Callback module   (Place implements callbacks)

В нашем конкретном случае модуль Access (являющийся Behaviour module), который
описывает какие callback-и нужны.
Callback module - это модуль внутри себя реализующий описанные в Behaviour
модуле функции-коллбеки.


####  реализуем Access Behaviour для своей структуры Place
```elixir
defmodule MyCalendar.Model.EventStruct do
  defmodule Place do
    @behaviour Access                  # (1)
    @enforce_keys [:office, :room]

    defstruct [:office, :room]

    @impl true                         # (3)
    def fetch(place, key) do           # (2)
      # todo
    end
  end
  # ...
end
```
- 1 так мы говорим компилятору что данный модуль Place реализует конкретное
указанное behaviour. Компилятор обязан будет проверить наличие всех нужных
коллбек-функций внутри такого модуля.
- 2 описываем функцию коллбек нужную для реализации указанного поведения
(behaviour)
- 3 аттрибут `@impl` видимо это аналог аннотации `@Override` в Java говорящий
о том, что данная функция это коллбек - для реализации поведения


```elixir
defmodule MyCalendar.Model.EventStruct do
  defmodule Place do
    @behaviour Access
    @enforce_keys [:office, :room]

    defstruct [:office, :room]

    @impl true
    def fetch(place, key) do
      # todo
    end

    @impl true
    def get_and_update(place, key, f) do
      # todo
    end

    @impl true
    def pop(place, key) do
      # todo
    end
  end
```
вот все функции нужные для реализации behaviour(интерфейса) Access
ради интереса закомментируем функцию pop и пробуем собрать проект:

```elixir
recompile
Compiling 1 file (.ex)
    warning: function pop/2 required by behaviour Access
    is not implemented (in module MyCalendar.Model.EventStruct.Place)
    │
  2 │   defmodule Place do
    │   ~~~~~~~~~~~~~~~~~~
    │
    └─ lib/model/event_struct.ex:2: MyCalendar.Model.EventStruct.Place (module)

Generated my_calendar app
```

> Начинаем реализовывать коллбеки для поведения Access

```elixir
iex> alias MyCalendar.Model.EventStruct.Place
MyCalendar.Model.EventStruct.Place

iex> place = %Place{office: "O1", room: "Ru"}
%MyCalendar.Model.EventStruct.Place{office: "O1", room: "Ru"}
```


```elixir
defmodule MyCalendar.Model.EventStruct do
  defmodule Place do
    @behaviour Access
    @enforce_keys [:office, :room]

    defstruct [:office, :room]

    @impl true
    def fetch(place, key) do # пример наивной реализации
      place[key]   # это синтаксис доступа к значению мапы по ключу
      # но под капотом для структуры оно работает через "поведение" Access
      # а значит будет вызываться эта же функция и в результате уйдём в безко
      # нечную рекусию вызова самого себя
    end
end
```

Поэтому  для правильной реализации нужен доступ через точку:
```elixir
    @impl true
    def fetch(place, :office), do: {:ok, place.office}
    def fetch(place, :room), do: {:ok, place.room}
    def fetch(_place, _), do: :error
```

Проверяю работу доступа через Access behaviour
```elixir
iex(3)> place[:room]
"Ru"

iex(4)> get_in(place, [:room])
"Ru"
```

Реализуем get_and_update

```elixir
defmodule MyCalendar.Model.EventStruct do
  defmodule Place do
    @behaviour Access
    @enforce_keys [:office, :room]

    defstruct [:office, :room]

    @impl true
    def fetch(place, :office), do: {:ok, place.office}
    def fetch(place, :room), do: {:ok, place.room}
    def fetch(_place, _), do: :error

    @impl true
    def get_and_update(place, :office, f) do
      {curr_val, new_val} = f.(place.office)
      place = %Place{place | office: new_val}
      {curr_val, new_place}
    end

    def get_and_update(place, :room, f) do
      {curr_val, new_val} = f.(place.room)
      new_place = %Place{place | room: new_val}
      {curr_val, new_place}
    end

    def get_and_update(_place, _, _f) do
      {nil, place}
    end

    @impl true
    def pop(place, key) do
      # todo
    end
  end
```

Проверяю работы get_and_update
```elixir
iex(11)> put_in(place, [:office], "O2")
%MyCalendar.Model.EventStruct.Place{office: "O2", room: "Ru"}
```

если не раализовать для :room или указать не существующий ключ, то такой
вызов просто вернёт не изменившийся "обьект"

#### оцениваем перспективу реализации Behaviour для своей структуры.
если посмотреть на код в которой мы реализовали только часть нужного для
реализации поведения Access, то становится ясным, что такой подход слишком
многословен и трудоёмок - нужно описывать каждый ключ своей структуры - а это
слишком долго и муторно.
Проще говоря возни с реализацией поведения для своих структур настолько много
что это вообще теряет всякий практический смысл. И обычно приходят к тому,
чтобы вместо того чтобы реализовывать все нужные для Access-behaviour коллбеки
проще реализовать свои конкретные специфичные функции для нужных действий.

ну и на 1м уровне менять ключи можно просто стандартным синтаксисом  без всяких
макросов и функций put_in
```elixir
iex> place = %Place{place | room: "Room 2"}
%MyCalendar.Model.EventStruct.Place{office: "O1", room: "Room 2"}
```

А вот для Event уже можно и добавить доп.функции:



```elixir
  defmodule Event do
    @enforce_keys [:title, :place, :time]

    defstruct [
      :title,
      :place,
      :time,
      {:participants, []},
      {:agenda, []}
    ]

    # своя функция для простоты работы без Access-behaviour
    def add_participant(event, participant) do
      # todo
    end
  end
```

Пример реализации. краткость достигается за счёт излечения нужных частей
через паттерн матчинг.
```elixir
    def add_participant(
          %Event{participants: participants} = event,
          %Participant{} = participant
        ) do
      participants = [participant | participants]
      %Event{event | participants: participants}
    end
```
указание структур в аргументах функции гарантирует что если что-то решит
передать в эту функцию что-то не то то получит ошибку.


создаю экземпляр сущности для испытания функции добавления нового участника
```elixir
iex> event = MyCalendar.sample_event_struct()
%MyCalendar.Model.EventStruct.Event{
  title: "Weekly Team Meeting",
  place: %MyCalendar.Model.EventStruct.Place{
    office: "Office #1",
    room: "#Room 42"
  },
  time: ~U[2025-04-09 17:17:00Z],
  participants: [
    %MyCalendar.Model.EventStruct.Participant{
      name: "Bob",
      role: :project_manager
    },
    %MyCalendar.Model.EventStruct.Participant{name: "Petya", role: :developer},
    %MyCalendar.Model.EventStruct.Participant{name: "Kate", role: :qa}
  ],
  agenda: [
    %MyCalendar.Model.EventStruct.Topic{
      title: "Interview",
      description: "candidat for developer position",
      priority: :medium
    },
    %MyCalendar.Model.EventStruct.Topic{
      title: "Direction",
      description: "disscuss main goals",
      priority: :medium
    }
  ]
}
```

Создаю "обьект"(экземпляр сущности) нового участника:
```elixir
iex> helen = %MyCalendar.Model.EventStruct.Participant{name: "Helen", role: :pm}
%MyCalendar.Model.EventStruct.Participant{name: "Helen", role: :pm}
```

Проверяем добавление
```elixir
iex> MyCalendar.Model.EventStruct.Event.add_participant(event, helen)
%MyCalendar.Model.EventStruct.Event{
  title: "Weekly Team Meeting",
  place: %MyCalendar.Model.EventStruct.Place{
    office: "Office #1",
    room: "#Room 42"
  },
  time: ~U[2025-04-09 17:17:00Z],
  participants: [
    %MyCalendar.Model.EventStruct.Participant{name: "Helen", role: :pm}, # <<<
    %MyCalendar.Model.EventStruct.Participant{
      name: "Bob",
      role: :project_manager
    },
    %MyCalendar.Model.EventStruct.Participant{name: "Petya", role: :developer},
    %MyCalendar.Model.EventStruct.Participant{name: "Kate", role: :qa}
  ],
  agenda: [
    %MyCalendar.Model.EventStruct.Topic{
      title: "Interview",
      description: "candidat for developer position",
      priority: :medium
    },
    %MyCalendar.Model.EventStruct.Topic{
      title: "Direction",
      description: "disscuss main goals",
      priority: :medium
    }
  ]
}
```

```elixir
    # aka update by name
    def replace_participant(
          %Event{participants: participants} = event,
          %Participant{} = new_participant
        ) do
      participants = Enum.filter(participants, fn p ->
        p.name != new_participant.name
      end)
      participants = [new_participant | participants]
      %Event{event | participants: participants}
    end
```

```elixir
iex> alias MyCalendar.Model.EventStruct.Participant
MyCalendar.Model.EventStruct.Participant

iex> helen = %Participant{helen | role: :devops}
%MyCalendar.Model.EventStruct.Participant{name: "Helen", role: :devops}
```

достаю значение где добавлял старое значение helen:
```elixir
iex> event = v(17)
%MyCalendar.Model.EventStruct.Event{
  title: "Weekly Team Meeting",
  place: %MyCalendar.Model.EventStruct.Place{
    office: "Office #1",
    room: "#Room 42"
  },
  time: ~U[2025-04-09 17:17:00Z],
  participants: [
    %MyCalendar.Model.EventStruct.Participant{name: "Helen", role: :pm},
    %MyCalendar.Model.EventStruct.Participant{name: "Bob", role: :project_manager},
    %MyCalendar.Model.EventStruct.Participant{name: "Petya", role: :developer},
    %MyCalendar.Model.EventStruct.Participant{name: "Kate", role: :qa}
  ],
  agenda: [
    %MyCalendar.Model.EventStruct.Topic{
      title: "Interview",
      description: "candidat for developer position",
      priority: :medium
    },
    %MyCalendar.Model.EventStruct.Topic{
      title: "Direction",
      description: "disscuss main goals",
      priority: :medium
    }
  ]
}
```

```elixir
iex> alias MyCalendar.Model.EventStruct, as: S
MyCalendar.Model.EventStruct


iex> alias MyCalendar.Model.EventStruct, as: S
MyCalendar.Model.EventStruct

iex> S.Event.replace_participant(event, helen)
%MyCalendar.Model.EventStruct.Event{
  title: "Weekly Team Meeting",
  place: %MyCalendar.Model.EventStruct.Place{office: "Office #1",room: "#Room 42"},
  time: ~U[2025-04-09 17:17:00Z],
  participants: [
    %MyCalendar.Model.EventStruct.Participant{name: "Helen", role: :devops}, # <<
    %MyCalendar.Model.EventStruct.Participant{name: "Bob", role: :project_manager},
    %MyCalendar.Model.EventStruct.Participant{name: "Petya", role: :developer},
    %MyCalendar.Model.EventStruct.Participant{name: "Kate", role: :qa}
  ],
  agenda: [
    %MyCalendar.Model.EventStruct.Topic{
      title: "Interview",
      description: "candidat for developer position",
      priority: :medium
    },
    %MyCalendar.Model.EventStruct.Topic{
      title: "Direction",
      description: "disscuss main goals",
      priority: :medium
    }
  ]
}
```

Таким образом подходим к понимаю, что модуль Access хорош для словарей(Map)
кортежей и списков, но не для структур. Т.к. для структур нужно слишком много
возни для реализации нужных коллбеков. Для структур проще и лучше добавлять
свои функции нужные, для конкретных кастомных действий потипу
add_participant и replace_participant


К данному моменту мы рассмотрели три способа моделирования предметной области
- кортежи (ныне считается устаревшим и годным только для малых проектов)
- словари(map)
- структуры(struct)

Словари и Структуры - рабочая основа для построения моделей.
Уже сейчас заметны существенные отличия между ними
- словарь - динамическая структура данных (можно добавлять любые ключи)
- структура - статическая стркутура данных с фиксированным и чётко заданным
  набором ключей, "добавление лишнего" контролируется на уровне компилятора

- Словари позволяют удобно использовать get_in, put_in, update_in
- структры позволяют это делать в теории, а на практике для этого нужно
  слишком много бойлерплейт кода, что на практике "почти не юзебельно"

В общем структуры более жесткий тип данных, и их достоинство в том, что
они дают гарантии по ключам, запрещая доступ к неизвестным ключам, но
обращаться с данными не так просто как можно у Map.

#### Новый уровень абстракции Смеха из либы Ecto
В библиотеке Ecto есть еще один новый уровень абстракции (поверх struct) -
"схема". Схема умеет превращать словари в структуры с валидацией ключей и
значений.
Во всех веб-проектах скорее всего будут применяться фрейморки Phoenix и
библиотека Ecto с её схемами. Но это уже сторониии библиотки, главная цель
текущего курса - изучить самые базовые вещи самого языка эликсир. И только
стандартные вещи из него.




## 07.04 Struct с указанием типов (Typed Struct)

Моделируем календарное событие используя структуры с указанием типов
Эликсир - язык частично(опционально) поддерживающий статическую типизацию.
То есть статит.-ю типизации можно использоваться, а можно и не использовать.

Обычно во многих случаях статическая типизация полезна:
- позволяет исключить определённый класс ошибок
  еще на этапе компиляции, так чтобы они не вылезли в рантайме (в проде).
- даёт компилятору больше инфы для оптимизации кода
  пока это не случай эликсира, но для большинства языков со статической типизацией
  эта актуально.
- описание типов в коде улучшает читаемость кода (документируемость)

Эликсировские интсрументы для статической типизации
- Gradual Set-Threoretic Types - это про типы основанные на теории множеств
  gradual - "постепенно внедряемые". Автор языка - Jose Valim, подключил к этому
  делу специалистов в системах типов и разработке компиляторов, глубоко понимающих
  данную тему. С их помощью была сначала разработана теоритическая модель, и
  на лето 2024 было начато ей внедрение. В версии 1.17 уже введены некие эл-ты
  этой новой системы типов, которые можно использовать в своём коде.
- Dialyzer - инструмент для статического анализа. Создан еще в 1990хх годах для
  Erlang-а, используется как отдельный от компилятора самостоятельный иснтрумент

статический анализатор кода - инструмент который на основе исходников ищет в
коде какие-то косяки, проблемы и баги. Например вызов не существующих функций,
не досягаемых блоков кода. Так же он анализирует типы и проверяет соответствие
типов. Если типы не описаны пытается их сам как-то вывести автоматически. Но
если разработчики в сиходниках явно описывают используемые типы, то его работа
во многом упрощается и даёт более стабильный и надежный результат проверок.

Dialyzer расшифровка:
DIscrepancy AnalYZer for ERlang programs

Изначально Dialyzer был создан специально для Эрланга, и напрямую с Эликсиром
не работает, но есть библиотека, через которую его можно использовать с Эликсиром.

### Что будем делать в этом уроке

- опишим модель нашей предметной области с помощью структур, но к этим струтурам
добавим описание типов и познакомимся с работой Dialyzer и где он полезен.

для наглядности создадим отдельный новый файл event_struct убрав отдуда код
который писали для реализации Access-behaviour.

./lib/model/event_typed_struct.ex
```elixir
defmodule MyCalendar.Model.EventTypedStruct do
  defmodule Place do
    @enforce_keys [:office, :room]

    defstruct [:office, :room]
  end

  defmodule Participant do
    @enforce_keys [:name, :role]

    defstruct [:name, :role]
  end

  defmodule Topic do
    @enforce_keys [:title]

    defstruct [
      :title,
      :description,
      {:priority, :medium}
    ]
  end

  defmodule Event do
    @enforce_keys [:title, :place, :time]

    defstruct [
      :title,
      :place,
      :time,
      {:participants, []},
      {:agenda, []}
    ]
  end
end
```

Тепень начинаем прописывать типы для Dialyzer:
у нас и так ключи полей дублируются в @enforce_keys и нужно их дублировать еще раз
для типов.

создаём тип с именем t (это такое соглашение в стандартной библиотеки Эликсир
вот примеры: String.t() DateTime.t(), Regex.t()

```sh
  String.t()
# ^1     ^2
```


- 1. Внутри модуля описываем структуру
- 2. к этой структуре мы описываем тип, давая ему имя `t`
  тип - это просто структура в виде обычной Map где описаны типы всех полей
  данной структуры.


```elixir
defmodule MyCalendar.Model.EventTypedStruct do
  defmodule Place do
    @type t() :: %Place{                # 1 t - имя типа по соглашению
            office: String.t(),         # 2 имя поля и её тип
            role: String.t(),           # 3 имя второго поля и его тип
          }
    @enforce_keys [:office, :room]

    defstruct [:office, :room]
  end
  # ...
end
```

Как видим по факту мы здесь 3 раза дублируем одно и тоже перечисление полей
описываемой структуры. Увы так сложилось по историческим причинам языка

> TypedStruct

Вообще эта проблема дублирования кода описания типов полей структур решается
через стороннюю библиотеку TypedStruct. Эта либа позволяет описывать ключи
(поля структуры) через макросы, где можно сразу указывать и имя ключа и его тип
и значение по умолчанию. Ну и естественно под коптом эти макросы раскрываются в
код описаный в примере выше.

В большинстве эликсир-проектов используется либа `Ecto` (работа с базами данных)
(Даже если это не веб-проект то очень часто всё равно используется ecto)
В ecto есть абстракции повех структур называемые "схема". Так вот "схемы" тоже
решают эту проблему дублирования описания типов структур, примерно таким же
образом как либа TypedStruct.

В этом курсе мы изучаем базу именно самого языка Эликсир, без всяких там
сторонних библиотек упрощающих жизнь. Поэтому пока придётся использовать такой
"мокрый" дублирующийся бойлерплейт код для описания обязательности ключей(полей)
и их типов.


```elixir
defmodule MyCalendar.Model.EventTypedStruct do
  defmodule Place do
    @type t() :: %__MODULE__{   # << это макрос имени структуры модуля
            office: String.t(),
            role: String.t(),
          }
    @enforce_keys [:office, :room]

    defstruct [:office, :room]
  end
  # ...
end
```

`__MODULE__` - Это макрос, раскрывающийся в имя модуля внутри которого он задан.
он особенно полезен, когда нутри модуля несколько раз упоминается его имя:

```elixir
  defmodule Event do
    #       ^^^^^
    @enforce_keys [:title, :place, :time]

    defstruct [...]

    def add_participant(
          %Event{participants: participants} = event,
          #^^^^^
          %Participant{} = participant
        ) do
      participants = [participant | participants]
      %Event{event | participants: participants}
      #^^^^^
    end

    # aka update by name
    def replace_participant(
          %Event{participants: participants} = event,
          #^^^^^
          %Participant{} = new_participant
        ) do
      participants = Enum.filter(participants, fn p ->
        p.name != new_participant.name
      end)
      participants = [new_participant | participants]
      %Event{event | participants: participants}
      #^^^^^
    end
  end
```

Это очень полезно особенно когда нужно переименовать модуль.

#### о базовых типах встроенных в сам Erlang
это насление от Erlang-а, которое активно используется и в Elixir тоже:

- atom(), boolean(), number(), pos_integer()

смотри доку по эрлангу.

Эликсировские же типы все в виде `String.t()`

```elixir
  defmodule Event do
    @type t() :: %__MODULE__{
      title: String.t(),
      place: Place.t(),
      time: DateTime.t(),
      participants: list(Participant.t()), # аналог List<Participant> в java
      agenda: list(Topic.t()) # есть синт. сахар [Topic.t()]
    }

    @enforce_keys [:title, :place, :time]

    defstruct [
      :title,
      :place,
      :time,
      {:participants, []},
      {:agenda, []}
    ]
  end
```

Есть синстаксический сахар для `list(MyStruct.t())` -> `[MyStruct.t()]`
```elixir
 defmodule Event do
    @type t() :: %__MODULE__{
            title: String.t(),
            place: Place.t(),
            time: DateTime.t(),
            participants: [Participant.t()], # synt. sugar list(Participant.t())
            agenda: [Topic.t()]
          }
```

для Map:

```elixir
map(atom(), integer())  # analog of Map<Atom, Integer>
```

##### проверяем корректность кода через компиляцию проекта

```sh
mix compile
Compiling 5 files (.ex)
Generated my_calendar app
```

Функция для создания экземпляра данного события.

по сути это копипаста, только используем другой модуль и алиас
```elixir
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

    %TS.Event{
      title: "Weekly Team Meeting",
      place: place,
      time: time,
      participants: participants,
      agenda: agenda
    }
  end
```

проверяем
```sh
iex -S mix
```

```elixir
iex> event = MyCalendar.sample_event_typed_struct()
%MyCalendar.Model.EventTypedStruct.Event{
  title: "Weekly Team Meeting",
  place: %MyCalendar.Model.EventTypedStruct.Place{
    office: "Office #1",
    room: "#Room 42"
  },
  time: ~U[2025-04-09 17:17:00Z],
  participants: [
    %MyCalendar.Model.EventTypedStruct.Participant{
      name: "Bob",
      role: :project_manager
    },
    %MyCalendar.Model.EventTypedStruct.Participant{
      name: "Petya",
      role: :developer
    },
    %MyCalendar.Model.EventTypedStruct.Participant{name: "Kate", role: :qa}
  ],
  agenda: [
    %MyCalendar.Model.EventTypedStruct.Topic{
      title: "Interview",
      description: "candidat for developer position",
      priority: :medium
    },
    %MyCalendar.Model.EventTypedStruct.Topic{
      title: "Direction",
      description: "disscuss main goals",
      priority: :medium
    }
  ]
}
```


### подключаем к проекту Dialyzer

- зачем все эти типы и как их использовать с Dialyzer
- будем создавать проблемы и пытаться их находить через Dialyzer

идём на https://hex.pm/packages/dialyxir
dialyxir - это либа добавляющая поддержку Dialyzer

подтягиваем либу из сети
```sh
mix deps.get

Resolving Hex dependencies...
Resolution completed in 0.132s
New:
  dialyxir 1.4.5
  erlex 0.2.7
* Getting dialyxir (Hex package)
* Getting erlex (Hex package)
```

компилируем
```sh
mix compile

==> erlex
Compiling 1 file (.xrl)
Compiling 1 file (.yrl)
src/erlex_parser.yrl: Warning: conflicts: 27 shift/reduce, 0 reduce/reduce
Compiling 2 files (.erl)
Compiling 1 file (.ex)
Generated erlex app
==> dialyxir
Compiling 67 files (.ex)
Generated dialyxir app
==> my_calendar
Generated my_calendar app
```
- при этом сначала компилируюся все библиотеки-зависимости,
- затем уже исходники проекта

запускаем Dialyzer

при превом запуске Dialyzer будет создавать Persistent Lookup Tables (PLT)
- это спец. файлы хранящие инфу о имеющихся в проекте модулях и типах.
PLT состоит из
- текущей используемой версии Elixir (то есть берутся все исходники Elixir-а)
- все зависимости проекта и прямые и транзитивные
- исходники самого проекта

Полное создание PLT таблиц с нуля идёт только при первом запуске, и занимает
обычно приличное время. Затем сгенерированные PLT данные кэшируются и исп-ся
при последующих запусках dialyzer

```sh
mix dialyzer
```
output:
```html
Finding suitable PLTs
Checking PLT...
[:compiler, :crypto, :dialyxir, :dialyzer, :elixir, :erlex, :erts, :kernel, :logger, :mix, :my_calendar, :stdlib, :syntax_tools]
Looking up modules in dialyxir_erlang-26.2.1_elixir-1.18.3_deps-dev.plt
Looking up modules in dialyxir_erlang-26.2.1_elixir-1.18.3.plt
Looking up modules in dialyxir_erlang-26.2.1.plt
Finding applications for dialyxir_erlang-26.2.1.plt
Finding modules for dialyxir_erlang-26.2.1.plt
Creating dialyxir_erlang-26.2.1.plt
Looking up modules in dialyxir_erlang-26.2.1.plt
Removing 3 modules from dialyxir_erlang-26.2.1.plt
Checking 18 modules in dialyxir_erlang-26.2.1.plt
Adding 191 modules to dialyxir_erlang-26.2.1.plt
done in 0m23.02s
Finding applications for dialyxir_erlang-26.2.1_elixir-1.18.3.plt
Finding modules for dialyxir_erlang-26.2.1_elixir-1.18.3.plt
Copying dialyxir_erlang-26.2.1.plt to dialyxir_erlang-26.2.1_elixir-1.18.3.plt
Looking up modules in dialyxir_erlang-26.2.1_elixir-1.18.3.plt
Checking 209 modules in dialyxir_erlang-26.2.1_elixir-1.18.3.plt
Adding 273 modules to dialyxir_erlang-26.2.1_elixir-1.18.3.plt
done in 0m21.8s
Finding applications for dialyxir_erlang-26.2.1_elixir-1.18.3_deps-dev.plt
Finding modules for dialyxir_erlang-26.2.1_elixir-1.18.3_deps-dev.plt
Copying dialyxir_erlang-26.2.1_elixir-1.18.3.plt to dialyxir_erlang-26.2.1_elixir-1.18.3_deps-dev.plt
Looking up modules in dialyxir_erlang-26.2.1_elixir-1.18.3_deps-dev.plt
Checking 482 modules in dialyxir_erlang-26.2.1_elixir-1.18.3_deps-dev.plt
Adding 304 modules to dialyxir_erlang-26.2.1_elixir-1.18.3_deps-dev.plt
done in 1m12.02s
No :ignore_warnings opt specified in mix.exs and default does not exist.

Starting Dialyzer
[
  check_plt: false,
  init_plt: ~c"./my_calendar/_build/dev/dialyxir_erlang-26.2.1_elixir-1.18.3_deps-dev.plt",
  files: [~c"./my_calendar/_build/dev/lib/my_calendar/ebin/Elixir.MyCalendar.Model.EventMap.Event.beam",
   ~c"./my_calendar/_build/dev/lib/my_calendar/ebin/Elixir.MyCalendar.Model.EventMap.Participant.beam",
   ~c"./my_calendar/_build/dev/lib/my_calendar/ebin/Elixir.MyCalendar.Model.EventMap.Place.beam",
   ~c"./my_calendar/_build/dev/lib/my_calendar/ebin/Elixir.MyCalendar.Model.EventMap.Topic.beam",
   ~c"./my_calendar/_build/dev/lib/my_calendar/ebin/Elixir.MyCalendar.Model.EventMap.beam",
   ...],
  warnings: [:unknown]
]
Total errors: 1, Skipped: 0, Unnecessary Skips: 0
done in 0m3.92s
lib/model/event_struct.ex:32:9:callback_type_mismatch
Type mismatch for @callback pop/2 in Access behaviour.

Expected type:
{_, Keyword.t() | map()}

Actual type:
nil

________________________________________________________________________________
done (warnings were emitted)
Halting VM with exit status 2
```


`Starting Dialyzer` - с этой строки начинается вывод инфы об статическом анализе
и найденых в проекте ошибках:

```html
lib/model/event_struct.ex:32:9:callback_type_mismatch
Type mismatch for @callback pop/2 in Access behaviour.

Expected type:
{_, Keyword.t() | map()}

Actual type:
nil

________________________________________________________________________________
```
Это говорит о том, что найдена одна ошибка в модуле event_struct.ex
в функции коллбеке для Access-behaviour, которую мы в прошлый раз добавили
как заглушку но не дописали её до конца.

- место где найдена ошибка и что не так:
`Type mismatch for @callback pop/2 in Access behaviour.` -
 не правильный тип для коллбека-функции pop/2
 то, что ожидается(возвращаемый тип) и то что реально есть в коде
```html
Expected type:
{_, Keyword.t() | map()}

Actual type:
nil
```
исправляем место в коде с ошибкой
```elixir
    @impl true
    def pop(place, _key) do
      place                        # +
    end
```

перезапусаем
```sh
mix dialyzer
```
```html
Compiling 1 file (.ex)
Generated my_calendar app
Finding suitable PLTs
Checking PLT...
[:compiler, :crypto, :dialyxir, :dialyzer, :elixir, :erlex, :erts, :kernel, :logger, :mix, :my_calendar, :stdlib, :syntax_tools]
PLT is up to date!
No :ignore_warnings opt specified in mix.exs and default does not exist.

Starting Dialyzer
[ check_plt: false, ...], warnings: [:unknown] ]

Total errors: 0, Skipped: 0, Unnecessary Skips: 0
done in 0m3.97s
done (passed successfully)
```


## создаём проблемы типов в модуле event_typed_struct

заменяем тип Place.t() на не существующий модуль Location.t()

```elixir
  defmodule Event do
    @type t() :: %__MODULE__{
            title: String.t(),
            place: Location.t(), # place: Place.t(),        <<<<
            time: DateTime.t(),
            participants: [Participant.t()],
            agenda: [Topic.t()]
          }
    # ...
  end
```

Проверяем скомпилиться ли это? Да - молча значит ошибок нет
(компилятор по сути игнорирует сложные описания типов внутри @type)
```sh
mix compile
```

запускаем проверку
```sh
mix dialyzer
```
```html
Total errors: 1, Skipped: 0, Unnecessary Skips: 0
done in 0m4.0s
lib/model/event_typed_struct.ex:42:28:unknown_type
Unknown type: Location.t/0.
```

Dialyzer говорит о том, что обнаружен не известный тип.


Location.t() -> location()

```elixir
  defmodule Event do
    @type t() :: %__MODULE__{
            title: String.t(),
            place: location(), # place: Place.t(),
            time: DateTime.t(),
            # synt. sugar list(Participant.t())
            participants: [Participant.t()],
            agenda: [Topic.t()]
          }
```

```sh
mix compile
```
```html
Compiling 1 file (.ex)

== Compilation error in file lib/model/event_typed_struct.ex ==
** (Kernel.TypespecError) lib/model/event_typed_struct.ex:40: type location/0 undefined (no such type in MyCalendar.Model.EventTypedStruct.Event)
    (elixir 1.18.3) lib/kernel/typespec.ex:980: Kernel.Typespec.compile_error/2
    (elixir 1.18.3) lib/kernel/typespec.ex:568: anonymous fn/6 in Kernel.Typespec.typespec/4
    (stdlib 5.2) lists.erl:1706: :lists.mapfoldl_1/3
    (stdlib 5.2) lists.erl:1707: :lists.mapfoldl_1/3
    (elixir 1.18.3) lib/kernel/typespec.ex:582: Kernel.Typespec.typespec/4
    (elixir 1.18.3) lib/kernel/typespec.ex:308: Kernel.Typespec.translate_type/2
    (stdlib 5.2) lists.erl:1706: :lists.mapfoldl_1/3
    (elixir 1.18.3) lib/kernel/typespec.ex:235: Kernel.Typespec.translate_typespecs_for_module/2
```

- type location/0 undefined (no such type in MyCalendar.Model.EventTypedStruct.Event)
здесь компилятор предупреждает что в коде используется нигде не найденый тип

пробуем запустить Dialyzer И видем что он даже не запускается - это потому что
исходник не компилируется и компиляция валится с ошибкойл

#### создаём ошибку: вызов не существующей функции

```elixir
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

    TS.Event.add_participant(event, nil)     # <<<
  end
```

```sh
 mix compile
    warning: MyCalendar.Model.EventTypedStruct.Event.add_participant/2 is undefined or private
    │
 98 │     TS.Event.add_participant(event, nil)
    │              ~
    │
    └─ lib/my_calendar.ex:98:14: MyCalendar.sample_event_typed_struct/0
```
выдаёт только предупреждение а не ошибку компиляции.


```sh
mix dialyzer
```
```html
Total errors: 1, Skipped: 0, Unnecessary Skips: 0
done in 0m4.06s
lib/my_calendar.ex:98:14:call_to_missing
Call to missing or private function MyCalendar.Model.EventTypedStruct.Event.add_participant/2.
________________________________________________________________________________
done (warnings were emitted)
Halting VM with exit status 2
```
- Call to missing or private function  - попытка вызова не существующей или
  приватной функции

Добавим заглушку для этой функции и посмотрим на реакиции compile и dialyzer

```elixir
  defmodule Event do
    # ...

    def add_participant(event, _participant) do # просто заглушка без реализации
      event
    end
  end
```
```sh
mix compile
Compiling 1 file (.ex)
Compiling 1 file (.ex)
Generated my_calendar app
```

```sh
mix dialyzer
Total errors: 0, Skipped: 0, Unnecessary Skips: 0
done in 0m4.05s
done (passed successfully)
```
ошибок нет.

Да логически add_participant не правильна с точки зрения приложения, потому что
ничего не дает, кроме как возвращает тот же event без изменений, но с точки
зрения статического анализа здесь всё корректно.

#### добавляем паттерн матчинг в add_participant

```elixir
    # def add_participant(event, participant) do                          (-)
    def add_participant(%Event{} = event, %Participant{} = participant) do
      event
    end
```
Это делается для того чтобы в runtime проходила явная проверка входных параметров
то есть если типы не соответствуют кидалась ошибка

Запускаем компиляцию (Elixir 1.18.3)
```sh
mix compile
```
```html
Compiling 1 file (.ex)
    warning: incompatible types given to MyCalendar.Model.EventTypedStruct.Event.add_participant/2:

        MyCalendar.Model.EventTypedStruct.Event.add_participant(event, nil)

    given types:

        (
          %MyCalendar.Model.EventTypedStruct.Event{
            agenda:
              non_empty_list(%MyCalendar.Model.EventTypedStruct.Topic{
                description: binary(),
                priority: :medium,
                title: binary()
              }),
            participants:
              non_empty_list(%MyCalendar.Model.EventTypedStruct.Participant{
                name: binary(),
                role: :developer or :project_manager or :qa
              }),
            place: %MyCalendar.Model.EventTypedStruct.Place{office: binary(), room: binary()},
            time: %DateTime{
              calendar: Calendar.ISO,
              day: integer(),
              hour: integer(),
              microsecond: {integer(), integer()},
              minute: integer(),
              month: integer(),
              second: integer(),
              std_offset: integer(),
              time_zone: binary(),
              utc_offset: integer(),
              year: integer(),
              zone_abbr: binary()
            },
            title: binary()
          },
          nil
        )

    but expected one of:

        (
          dynamic(%MyCalendar.Model.EventTypedStruct.Event{
            agenda: term(),
            participants: term(),
            place: term(),
            time: term(),
            title: term()
          }),
          dynamic(%MyCalendar.Model.EventTypedStruct.Participant{name: term(), role: term()})
        )

    where "event" was given the type:

        # type: %MyCalendar.Model.EventTypedStruct.Event{
          agenda:
            non_empty_list(%MyCalendar.Model.EventTypedStruct.Topic{
              description: binary(),
              priority: :medium,
              title: binary()
            }),
          participants:
            non_empty_list(%MyCalendar.Model.EventTypedStruct.Participant{
              name: binary(),
              role: :developer or :project_manager or :qa
            }),
          place: %MyCalendar.Model.EventTypedStruct.Place{office: binary(), room: binary()},
          time: %DateTime{
            calendar: Calendar.ISO,
            day: integer(),
            hour: integer(),
            microsecond: {integer(), integer()},
            minute: integer(),
            month: integer(),
            second: integer(),
            std_offset: integer(),
            time_zone: binary(),
            utc_offset: integer(),
            year: integer(),
            zone_abbr: binary()
          },
          title: binary()
        }
        # from: lib/my_calendar.ex:90:11
        event = %MyCalendar.Model.EventTypedStruct.Event{
          title: "Weekly Team Meeting",
          place: place,
          time: time,
          participants: participants,
          agenda: agenda
        }

    typing violation found at:
    │
 98 │     TS.Event.add_participant(event, nil)
    │              ~
    │
    └─ lib/my_calendar.ex:98:14: MyCalendar.sample_event_typed_struct/0

Generated my_calendar app
```


Смотрим что скажет Dialyzer
```sh
mix dialyzer
```
```html
Total errors: 2, Skipped: 0, Unnecessary Skips: 0
done in 0m4.1s
lib/my_calendar.ex:74:7:no_return
Function sample_event_typed_struct/0 has no local return.
________________________________________________________________________________
lib/my_calendar.ex:98:14:call
The function call will not succeed.

MyCalendar.Model.EventTypedStruct.Event.add_participant(
  _event :: %MyCalendar.Model.EventTypedStruct.Event{
    :agenda => [
      %MyCalendar.Model.EventTypedStruct.Topic{
        :description => <<_::152, _::size(96)>>,
        :priority => :medium,
        :title => <<_::72>>
      },
      ...
    ],
    :participants => [
      %MyCalendar.Model.EventTypedStruct.Participant{
        :name => <<_::24, _::size(8)>>,
        :role => :developer | :project_manager | :qa
      },
      ...
    ],
    :place => %MyCalendar.Model.EventTypedStruct.Place{
      :office => <<_::72>>,
      :room => <<_::64>>
    },
    :time => %DateTime{
      :calendar => Calendar.ISO,
      :day => 9,
      :hour => 17,
      :microsecond => {0, 0},
      :minute => 17,
      :month => 4,
      :second => 0,
      :std_offset => 0,
      :time_zone => <<_::56>>,
      :utc_offset => 0,
      :year => 2025,
      :zone_abbr => <<_::24>>
    },
    :title => <<_::152>>
  },
  nil
)

will never return since the 2nd arguments differ
from the success typing arguments:

(
  %MyCalendar.Model.EventTypedStruct.Event{},
  %MyCalendar.Model.EventTypedStruct.Participant{}
)

```

lib/my_calendar.ex:98:14:call
The function call will not succeed.

место(номер строки) ошибки в коде:
```elixir
  def sample_event_typed_struct() do
    alias MyCalendar.Model.EventTypedStruct, as: TS
    # ...
    event = %TS.Event{...}

    TS.Event.add_participant(event, nil)   # << 98
  end
```

```elixir
  defmodule Event do
    @type t() :: %__MODULE__{... }

    @enforce_keys [:title, :place, :time]

    defstruct [...]

    def add_participant(%Event{} = event, %Participant{} = _participant) do
      event
    end

  end
```

дальше в выводе описывается как проходил вызов:
```elixir
MyCalendar.Model.EventTypedStruct.Event.add_participant(
  _event :: %MyCalendar.Model.EventTypedStruct.Event{...data.. },
  nil                                                             # <<<
)

will never return since the 2nd arguments differ
from the success typing arguments:

(
  %MyCalendar.Model.EventTypedStruct.Event{},
  %MyCalendar.Model.EventTypedStruct.Participant{}                 # <<<
)
```
то есть ошибка в том что ожидается 2й аргумент с типом
`MyCalendar.Model.EventTypedStruct.Participant` а преедаём nil.




#### заменяем в add_participant паттерн матчинг на @spec(спецификацию)
убираем паттер матчинг который гарантирует защиту в рантайме на спецификацию
```elixir
    # def add_participant(%Event{} = event, %Participant{} = _participant) do
    @spec add_participant(Event.t(), Participant.t()) :: Event.t()
    def add_participant(event, _participant) do
      event
    end
```

проверяем
```sh
mix compile
Compiling 1 file (.ex)
Generated my_calendar app
```

Dialyzer: (находит опять 2 ошибки)
```html
Total errors: 2, Skipped: 0, Unnecessary Skips: 0
done in 0m4.06s
lib/my_calendar.ex:74:7:no_return
Function sample_event_typed_struct/0 has no local return.
________________________________________________________________________________
lib/my_calendar.ex:98:14:call
The function call will not succeed.

MyCalendar.Model.EventTypedStruct.Event.add_participant(
  _event :: %MyCalendar.Model.EventTypedStruct.Event{
    :agenda => [
      %MyCalendar.Model.EventTypedStruct.Topic{
        :description => <<_::152, _::size(96)>>,
        :priority => :medium,
        :title => <<_::72>>
      },
      ...
    ],
    :participants => [
      %MyCalendar.Model.EventTypedStruct.Participant{
        :name => <<_::24, _::size(8)>>,
        :role => :developer | :project_manager | :qa
      },
      ...
    ],
    :place => %MyCalendar.Model.EventTypedStruct.Place{
      :office => <<_::72>>,
      :room => <<_::64>>
    },
    :time => %DateTime{
      :calendar => Calendar.ISO,
      :day => 9,
      :hour => 17,
      :microsecond => {0, 0},
      :minute => 17,
      :month => 4,
      :second => 0,
      :std_offset => 0,
      :time_zone => <<_::56>>,
      :utc_offset => 0,
      :year => 2025,
      :zone_abbr => <<_::24>>
    },
    :title => <<_::152>>
  },
  nil
)

breaks the contract
(t(), MyCalendar.Model.EventTypedStruct.Participant.t()) :: t()
```

- breaks the contract - говорит что идёт нарушение контракта указаннов в @spec
  то ожидается аргумент типа Participant.t() и реально передаётся nil

Предположим что есть два правильных варианта для 2го аргумента
- Participant.t() или atom() (nil - это атом)

```elixir
    @spec add_participant(Event.t(), Participant.t() | atom()) :: Event.t()
    def add_participant(event, _participant) do
      event
    end
```
Dialyzer:
```sh
Total errors: 0, Skipped: 0, Unnecessary Skips: 0
done in 0m4.09s
done (passed successfully)
```



## Dialyzer 1.4.3 странные и не понятные ошибки has no local return

в старых версиях Dialyzer (1.4.3) + elixir 1.15 была проблема с непонятной
ошибкой: из-за того, что Dialyzer не умел правльно обрабатывать значения по
умолчанию для defstruct, в результате чего затем думал что не хватает одного
ключа и это нарушение контракта, при этом выводя очень странную и не понятную
ошибку, по которой практически не возможно понять что вообще пошло не так:

```html
lib/my_calendar.ex:98:no_return
Function sample_event_typed_struc/0 has no local return.
```
дословно
- функция sample_event_typed_struct - не может вернуть правильное значение
  то есть Dialyzer думает что значение типа возращаемое изх add_participant
  не соответствует `%TS.Event{}`


Проверив позже на elixir 1.18.3 Оказалось что даже с версией Dialyzer 1.4.3
эта ошибка больше не возникает, так что походу улучшение было на уровне самого
языка а не просто в либе.


> "Раскручиваем" Dialyzer на вывод более подробного отчёта об ошибке.
ищем что может быть не так

да визуально кажется что всё в порядке, типы везде прописаны.


```elixir
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

    event = %TS.Event{                      # lnum:90   << (2)
      title: "Weekly Team Meeting",
      place: place,
      time: time,
      participants: participants,
      agenda: agenda
    }

    TS.Event.add_participant(event, nil)    # lnum:98  << (1) no_return
  end
```

- 1. хотя в самой функции add_participant возвращается то что пришло на вход и
нарушений типа Event.t() Dialyzer не обнаружил.
```elixir
    @spec add_participant(Event.t(), Participant.t() | atom()) :: Event.t()
    def add_participant(event, _participant) do
      event
    end
```

Чтобы разрулить подобную непонятную ошибку, нужна смекалка и опыт.
Интуиция подсказыват что похоже Dialyzer-у что-то не нравится в значении
event (2) (lnum:90). Что возможно что-то внутри этого значения не так.

Убедиться в этой догадке можно если убрать тип стуктуры Event.t() и заменить её
на map() (Тип Map): а затем перезапустить диалайзер
```elixir
    # @spec add_participant(Event.t(), Participant.t() | atom()) :: Event.t())
    @spec add_participant(map(), Participant.t() | atom()) :: map()
```
После этого диалайзер говорит что ошибок больше нет. А это значит то, что
диалайзеру не нравится именно значение event на строке 90.

Теперь можно посмотреть что не так копая глубже - поочередно исключая слабые места:
```elixir
    event = %TS.Event{                      # lnum:90
      title: "Weekly Team Meeting",
      place: place,
      time: time,
      participants: [], # participants,     # может проблема во вложенных типах?
      agenda: [], # agenda                  # проверим это подставив пустые листы
    }
```
после запуска диалайзер скажет всё ок. значит проблема или в participants либо в
agenda

```elixir
    participants = [
      %TS.Participant{name: "Bob", role: :project_manager},
      %TS.Participant{name: "Petya", role: :developer},
      %TS.Participant{name: "Kate", role: :qa},
    ]
    agenda = [
      %TS.Topic{title: "Interview", description: "candidat for developer position"},
      %TS.Topic{title: "Direction", description: "disscuss main goals"},
    ]
```
ну и понять какое из значение ломает так же просто - оставляем одно из них
и проверяем появится ли ошибка, приходим к тому что ошибка вылезает на agenda:
```elixir
    event = %TS.Event{
      # ...
      participants: participants,         # ok ошибок нет
      agenda: [], # agenda
    }
```
```elixir
    event = %TS.Event{
      # ...
      participants: [], #participants,
      agenda: agenda                        # ошибка!
    }
```

выяснив что Диалайзеру не нравится значение в agenda пробуем глянуть глубже
```elixir
    agenda = [
      # %TS.Topic{title: "Interview", description: "candidat for developer position"},
      %TS.Topic{title: "Direction", description: "disscuss main goals"},
    ]
```
После этого Dialyzer выдаст более подробную и понятную ошибку

```html
MyCalendar.Model.EventTypedStruct.Event.add_participant(
  _event :: %MyCalendar.Model.EventTypedStruct.Event(     # arg1
  # ... agenda, participants, place, time, title ...
  ),
  nil                                                     # arg2
)
breaks the contract
(t(), MyCalendar.Model.EventTypedStruct.Participant.t() | atom()) :: t()
```
Это говорит что Диалайзер думает что арг1 не соответствует ожидаемому типу.

Пробуем оставить только первую тему агенды убрав вторую
```elixir
    agenda = [
      %TS.Topic{title: "Interview", description: "candidat for developer position"},
      # %TS.Topic{title: "Direction", description: "disscuss main goals"},
    ]
```
теперь диалайзер говорит ошибок нет. Значит ошибка была в строчке
```elixir
 %TS.Topic{title: "Direction", description: "disscuss main goals"}
```
а здесь не указывается :priority которое в рантайме устанавливается в значение
по умолчанию: (Но в старых версиях Dialyzer не умел корректно с этим работать)


```elixir
  defmodule Topic do
    @type t() :: %__MODULE__{
            title: String.t(),
            description: String.t(),
            priority: :high | :medium | :low
          }

    @enforce_keys [:title]

    defstruct [
      :title,
      :description,
      {:priority, :medium}   # имя поля, значение по умолчанию
    ]
  end
```

значение по умолчанию указанное в defstruct выставляется именно в runtime и
для старых версий Dialyzer не известно на этапе компиляции

то есть если явно прописать значени то диалайзер скажет ошибок нет.
```elixir
 %TS.Topic{title: "Direction", description: "disscuss main goals", priority: :medium}
```


#### о полезностях Dialyzer и почему его стоит использовать со старта проекта

Dialyzer хотя местами может быть и не идеальным, и например на старых версиях
мог выдавать очень запутанные и не понятные ошибки, он всё таки считается
крайне полезным инструментом, который стоит использовать в своих проектах для
гарантирования качества и отлова ошибок еще на этапе разработки и компиляции,
а не в рантайме на проде.

Рекомендуется начинать использовать Dialyzer именно со старта проекта, с самого
начала написания кода. Если же начать использовать его уже на имеющейся кодовой
базе где он раньше не использовался то количество ошибок им найденое может
отбить желание их править, либо на это будет уходить очень много времени.
Придётся долго и упорно, поэтапно исправлять найденые ошибки.
Как правило основные такие найденые косяки будут не в ошибках в коде, а в
отсутствии спецификации(описания) типов. Когда типы либо вообще не указаны,
либо разработчик ошибается в используемых типах.

Так же хорошей практикой считается создание CI (Continuos Integration)
в который на коммиты добавляют запуск тестов и Dialyzer. так чтобы CI падал
если в коммитах есть какие-либо ошибки. как в тестах, так и в статической диагностике кода(выводе Dialyzer).


#### размещаем dialyzer как dev-зависимость

```sh
iex -S mix
```
```html
Erlang/OTP 26 [erts-14.2.1] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [jit:ns]

Warning: the `dialyxir` application's start function was called, which likely means you
did not add the dependency with the `runtime: false` flag. This is not recommended because
it will mean that unnecessary applications are started, and unnecessary applications are most
likely being added to your PLT file, increasing build time.
Please add `runtime: false` in your `mix.exs` dependency section e.g.:
{:dialyxir, "~> 0.5", only: [:dev], runtime: false}

Interactive Elixir (1.18.3) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
```

```elixir
  defp deps do
    [
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false}
      #                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
```

```sh
iex -S mix
Erlang/OTP 26 [erts-14.2.1] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [jit:ns]

Generated my_calendar app
Interactive Elixir (1.18.3) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
```


