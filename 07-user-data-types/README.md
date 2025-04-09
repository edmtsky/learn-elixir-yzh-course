# Урок 7 Пользовательские типы данных

- 07.01 Создание проекта и моделирование предметной области
  - Начало моделирование предметной области
  - Моделирование используя кортежи и списки.
- 07.02 Использование Map
- 07.03 Использование Struct
- 07.04 Struct с указанием типов
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

