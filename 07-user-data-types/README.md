# Урок 7 Пользовательские типы данных

- 07.01 Создание проекта и моделирование предметной области
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

компилируем
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


