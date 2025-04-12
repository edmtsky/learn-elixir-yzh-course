# Урок 9 Композиция функций

- 09_01 Задача на композицию функций
- 09_02 Решение 1. Вложенные case
- 09_03 Решение 2. Каждый case в отдельной функции
- 09_04 Решение 3. Использование исключений
- 09_05 Решение 4. Монада Result и оператор bind
- 09_06 Решение 5. Pipeline
- 09_07 Решение 6. do-нотация
- 09_08 Что такое монада?


### 09_01 Задача на композицию функций

Это последний урок данного курса. Здесь будем собирать в единое целое все свои
новые знания, и применим свои новые знания на практике.

Поднимимся чуть выше уровня язка, на более высокий, абстрактный уровень.
Поговорим на текие темы как абстракция, композиция и т.д.

Абстракция - это мощный инструмент в руках разработчика и архитектора.
абстракция это про то, чтобы взять что-то сложное, некую сложную функциональность
и представить её упрощенно, "спрятать за фасадом" - за неким API. Причем этот
API может быть очень простым и понятным, тогда как конкретная его реализация
может быть очень сложной и запутанной. Основная идея здесь упростить и облегчить
понимание и использование тяжелых для быстрого восприятия и понимания вещей.
Сложное абстрагируем упрощенным "фасадом", облегчая понимание того как им
пользоваться.

Компонент - это некий отдельный элемент абстракции, имеющий сложную реализацию
и упрощенный для понимания "фасад"(API) Компонеты как строительные блоки для
построения больших и сложных систем. Продумывание архитектуры системы - это
про то что беруться компоненты и соединяются друг с другом в разных пропорциях.
Хорошо продуманные компоненты будет легко комбинировать с друг с дрогом.
Когда компоненты комбинируются легко - говорят "хорошая абстракция".
Плохая абстракция - это когда комбинировать компоненты друг с другом либо
вообще не получается либо их комбинации "разваливаются". Плохая абстракция -
признак того, что реализуемые вещи не достаточно хорошо продуманы.

- В ООП компонентом является обьект.
- В ФП компонентом является либо
  - одна отдельная функция, тогда фасадом(API) такого компонента будут
    аргументы функции.
  - либо набор функций обьединённых в некий модуль
    например модуль Enum - обьединяющий функции для работы с коллекциями
    то есть и модуль тоже можно воспрнимать как своего рода фасад за которым
    прячется некая сложность реализации доступной функциональности.


#### о проектировании функций и их компоновке

- о том как проектировать функции так, чтобы их было удобно друг с другом компоновать
- какие могут возникнуть трудности и проблемы


Вот пример простейших функций.
(тривиальный случай)
```elixir
defmodule Composition do
  def f1(a) do
    a + 1
  end

  def f2(a) do
    a + 10
  end
end
```

эти две функции соединяются очень просто:
(пример тривиального соединения)
```elixir
iex> alias Composition, as: C
Composition

iex> C.f1(10)
11

iex> 10 |> C.f1 |> C.f2
```

пример первого не тривиального случая - у функции два рагумента

```elixir
  def f3(a, b) do
    a + b
  end
```

```elixir
iex> r C
{:reloaded, [Composition]}
iex> 10 |> C.f1 |> C.f2 |> C.f3(10)
31                      #       ^^ 2й аргумент(1й идёт через pipe)
```

еще один не тривиальный случай - возращаемое значение не число а кортеж

```elixir
  def f4(a) do
    {:ok, a + 1}
  end
```

есть такая ф-я последняя в цепочки - нет проблем

```elixir
iex> 10 |> C.f1 |> C.f2 |> C.f3(10) |> C.f4()
{:ok, 32}
```

а вот если f4 нужно разместить между другими функциями - нужен некий адаптер

```sh
iex> 10 |> C.f1 |> C.f2 |> C.f3(10) |> C.f4() |> C.f1()
** (ArithmeticError) bad argument in arithmetic expression: {:ok, 32} + 1
    :erlang.+({:ok, 32}, 1)
    composition.exs:3: Composition.f1/1
    iex:8: (file)
```

elem - вытащить значение кортежа по заданному индексу (начиная с 0)
```elixir
iex> 10 |> C.f1 |> C.f2 |> C.f3(10) |> C.f4() |> elem(1) |> C.f1()
33
```
то есть для того чтобы соединить между собой две функции f4 и f1
пришлось использовать доп. ф-ю elem()


> функция возращает разные типы значений.

как быть когда есть функция f5 которая может возращать разные структуры
либо кортежа либо просто атом :error

```elixir
  def f5(a) when a < 10 do
    {:ok, a + 1}
  end

  def f5(a) do
    :error
  end
```

Уже здесь при создании композиции функций и начинаются проблемы

к тому же внутри функций могут имется side-effect-ы(побочные действия), которые
просто посмотрев на "фасад"(цепочку вызова функций) можно и не отследить и
вообще не узнать о их существовании:
```elixir
  def f6(a) do
    drop_database() # side effect what changes something somewhere in the outside
    a + 42
  end
```

В развитых Функциональных Языках
таких как Haskell для соединения(композиции) всяких разных функций есть всякие
разные приспособы. например в Elixir есть оператор pip (|>), тогда как в Haskell
таких разных штук-приспособ довольно много. Можно например на лету как-то
преобразовывать вывод функций так чтобы его можно было перенаправлять в другую
функцию. Есть такие вещи как
- апликативные функкторы
- монады
- монадные трансформеры

Это есть в Haskell(ФП языке) но подобных вещей нет в Elixir.

Теперь осознав проблему, можно перейти к формулированию некой практической
задачи. Посмотреть на примере, как реализовать решение через функции так, чтобы
было эти функции было удобно компоновать двуг с другом.

Обсудим и попробуем 6 разных реализации:

- Решение 1. Вложенные case
- Решение 2. Каждый case в отдельной функции
- Решение 3. Использование исключений
- Решение 4. Монада Result и оператор bind
- Решение 5. Pipeline
- Решение 6. do-нотация

То есть у нас будут одни и те же функции
(которые одинаково называются и делают примерно одно и тоже)
и мы будем учиться проектировать их под разные способы компоновки
и соответственно по разному их затем компоновать.

Сначала мы опимем задачу которую будет решать и реализовывать,
а дальше используя разные способы компоновки будем решать ей каждый раз заново.

и в конце посомотрим на новый полученный опыт и придём к пониманию того,
какие способы стоит запомнить и использовать в своей практике, а какие можно
будет отбросит, просто зная что такое существует.


### постановка практической задачи(формулировка)

- есть некий веб-сервис
  (это не удивительная для современного прогроммирования задача.)
- в API на вход приходит некий json документ
- наш веб-сервис - это интернет магазин продающий книги

покупатель может
- зарегистрироваться в нашем интернет магазине,
- указать адрес доставки
- заказать некие книги(положить в корзину)
- мы этот заказ обрабатываем, собираем книги и привозим покупателю.

на каком-то этапе в наш веб-сервис приходит вот такой вот json:

```json
{
  "user": "Attis",
  "address": "Freedom str 7/42 City Country",
  "books": [
    {"title": "Domain Modeling Made Functional", "author": "Scott Wlaschin"},
    {"title": "Distributed systems for fun and profit", "author": "Mikito Takada"},
    {"title": "Adopting Elixir", "author": "Marx, Valim, Tate"},
  ]
}
```

этот Json описывает заказ
обязаности нашего сервиса при приёмке этого документа:
- провалидировать валидность Json-данных и соответствие схеме
- проверить действительно ли указанный покупатель(user) известен системе(зареган)
- проверить что покупатель аутентифицирован и авторизован
- провалидировать валидность адреса
- пройтись по списку книг и проверить их наличие
- после выполнения всех проверок - собрать обьект Order(Заказ)
  и отправляем его по системе на обработку, оплату и доставку.


короче задача
- провалидировать входящие данные
- создать валидный обьект типа Order
  (который по ходу дела опишем в виде структур)

шаги нужные для выполнения валидации:
- validate json document
- volidate user
- volidate address
- volidate book (list)
- make order

для упрощения Json у нас будет в виде Map, то есть упрощенно считаем что у нас
уже есть подключенная либа преобразующая json(строку) в Map

всё вышеописанное это будем описывать(реализовывать) в виде функций:

продумываем наши основные функции для требуемой функциональности
(стразу через спецификацию типов @spec)

```elixir
@spec validate_incoming_data(map()) :: {:ok, map()} | {:error, :invalid_incoming_data}
@spec validate_user(name :: String.t()) :: {:ok, User.t()} | {:error, :user_not_found}
@spec validate_address(String.t()) :: {:ok, Address.t()} | {:error, :invalid_address}
@spec validate_book(map()) :: {:ok, Book.t()} | {:error, :book_not_found}
@spec create_order(User.t(), Address.t(), [Book.t()]) :: Order.t()
```

- User - для упрощения будет иметь только имя без всяких там
  id, first_name, last_name. Имена считаем уникальным идентификатором.

в "идеальном мире" (happy path) композиция функций была бы такая:

```elixir
json
|> validate_incoming_data()
|> validate_user()
|> validate_address()
|> validate_book()     # list!
|> create_order()
```
просто все наши функции соединяем через оператор pipe

но увы у нас в системе и коде возможны ветвления
```elixir
{:ok, map()} | {:error, :invalid_incoming_data}
```
а оператор pipe это вообще не про ветвление

Весь этот урок мы и будем думать как реализовать соединение наших функций так
чтобы это было и красиво и понятно.




## 09_02 Решение 1. Вложенные case

подготовка
- создать новый проект
- описать модель данных
- создать валидирующие функции
- приступить в реализации первого варианта реализации и компоновки фун-ий


```sh
mix new bookshop
cd bookshop
```

закидываем тестовые данные которые и будем валидировать.

lib/bookshop.ex
```elixir
defmodule Bookshop do
  # Этот тот самый Json но в виде Elixir-словарей(Map)
  def test_data() do
    %{
      "user" => "Attis",
      "address" => "Freedom str 7/42 City Country",
      "books" => [
        %{
          "title" => "Domain Modeling Made Functional",
          "author" => "Scott Wlaschin"
        },
        %{
          "title" => "Distributed systems for fun and profit",
          "author" => "Mikito Takada"
        },
        %{
          "title" => "Adopting Elixir",
          "author" => "Marx, Valim, Tate"
        },
      ]
    }
  end
end
```

представим что у нас уже есть библиотека для десериализации, которая и будет
преобзовывать пришедший Json(строку) во вложенные Map-ы, котрые в виде запроса
и будет приходить в функцию обработчик контроллера.

> запускаем проект в консоли
```sh
iex -S mix
```

проверяем наши тестовые данные
```elixir
iex> alias Bookshop, as: B
Bookshop
iex> B.test_data
%{
  "address" => "Freedom str 7/42 City Country",
  "books" => [
    %{
      "author" => "Scott Wlaschin",
      "title" => "Domain Modeling Made Functional"
    },
    %{
      "author" => "Mikito Takada",
      "title" => "Distributed systems for fun and profit"
    },
    %{"author" => "Marx, Valim, Tate", "title" => "Adopting Elixir"}
  ],
  "user" => "Attis"
}
```


### описание модели данных

для простоты все модели у нас будут в одном модуле Model (без разделения на пакеты)
```sh
touch lib/model.ex
```

- .ex - так как у нас компилируемый модуль а не просто скрипт (exs)
```elixir
defmodule BookShoop.Model do
  # ...
end
```
смотрим на test_data и думаем какие нужны сущности
- User
- Address
- Book
- Order(Заказ) который и будет содержать в себе всё это


для упрощения пока не будем описывать типы входных параметров функций

```elixir
defmodule BookShoop.Model do

  defmodule User do
    defstruct [:id, :name]
  end

  defmodule Adress do
    defstruct [:state, :city, :other]
  end

  defmodule Book do
    defstruct [:title, :author]
  end

  defmodule Order do
    defstruct [:client, :address, :books]

    def created(client, address, books) do
      %__MODULE__{
        client: client,
        address: address,
        books: books
      }
    end
  end
end
```

валидация.
валидация должна быть в контроллере

./lib/controller.ex
```elixir

defmodule Bookshop.Controller do

  def handle(request) do
    #...
  end

end
```

Контроллер
- вызывает функции валидации
- формирует Order

функции валидации:
```elixir
@spec validate_incoming_data(map()) :: {:ok, map()} | {:error, :invalid_incoming_data}
@spec validate_user(name :: String.t()) :: {:ok, User.t()} | {:error, :user_not_found}
@spec validate_address(String.t()) :: {:ok, Address.t()} | {:error, :invalid_address}
@spec validate_book(map()) :: {:ok, Book.t()} | {:error, :book_not_found}
```

обычно функции валидации размещают в самих модулях соответствующих моделей.
здесь для простоты, все эти функции будут в контроллере. т.к. эти ф-и валидации
у нас будут по сути заглушками со случайной(далёкой от разумной) логикой -
рандомайзер будет случайно выдовать успех / не успех.

Получение рандомного числа - через Enum.random(1..10)
```elixir
defmodule Bookshop.Controller do
  alias Bookshop.Model, as: M

  # ...

  # примерно с вероятностью в 10% выдаёт фейл
  def rand_success() do
    Enum.random(1..10) > 1
  end

end
```

дальше копируем описанные выше спеки своих функций и по ним делаем релиазации
на основе rand_success - для того чтобы валидация проходила рандомно с 90% успеха

```elixir
defmodule Bookshop.Controller do
  alias Bookshop.Model, as: M

  def handle(request) do
  end

  @spec validate_incoming_data(map()) :: {:ok, map()} | {:error, :invalid_incoming_data}
  def validate_incoming_data(data) do
    if rand_success() do
      {:ok, data}
    else
      {:error, :invalid_incoming_data}
    end
  end

  @spec validate_user(name :: String.t()) :: {:ok, User.t()} | {:error, :user_not_found}
  def validate_user(name) do
    if rand_success() do
      {:ok, %M.User{id: name, name: name}}
    else
      {:error, :user_not_found}
    end
  end

  @spec validate_address(String.t()) :: {:ok, Address.t()} | {:error, :invalid_address}
  def validate_address(data) do
    if rand_success() do
      {:ok, %M.Address{other: data}}
    else
      {:error, :invalid_address}
    end
  end

  @spec validate_book(map()) :: {:ok, Book.t()} | {:error, :book_not_found}
  def validate_book(data) do
    if rand_success() do
      {:ok, %M.Book{title: data["title"], author: data["author"]}}
    else
      {:error, :book_not_found}
    end
  end

  def rand_success() do
    Enum.random(1..10) > 1
  end

end
```

теперь подключаемся к проекту через консоль и проверяем работу валидаторов
(иногда должно давать ошибки валидации для всех ф-й)
iex -S mix
```elixir
iex(1)> alias Bookshop, as: B
Bookshop
iex(2)> B.Controller.validate_incoming_data(42)
{:ok, 42}
...
iex(17)> B.Controller.validate_incoming_data(42)
{:error, :invalid_incoming_data}

iex(23)> B.Controller.validate_user("Attis")
{:ok, %Bookshop.Model.User{id: "Attis", name: "Attis"}}

iex(26)> B.Controller.validate_user("Attis")
{:error, :user_not_found}

iex(30)> B.Controller.validate_address("State City Other")
{:ok, %Bookshop.Model.Address{state: nil, city: nil, other: "State City Other"}}

iex(28)> B.Controller.validate_address("State City Other")
{:error, :invalid_address}

iex(32)> B.Controller.validate_book(%{"title" => "T" , "author" => "A"})
{:ok, %Bookshop.Model.Book{title: "T", author: "A"}}

iex(43)> B.Controller.validate_book(%{"title" => "T" , "author" => "A"})
{:error, :book_not_found}
```

подготовка закончена переходим к реализации 1го решения

### приступаем к реалиазации первого варианта решения

Так как у нас будет 6 вариантов решения, то сами эти реализации будем размещать
в отдельных модулях и зывать из из lib/controller.ex

```elixir
defmodule Bookshop.Solution1 do

  def handle(data) do
    # solution-1 impl here
  end

end
```
```elixir
defmodule Bookshop.Controller do
  alias Bookshop.Model, as: M

  def handle(request) do
    Bookshop.Solution1.handle(request)  # <<<<
  end

  # ...
```

Первое решение(Solution) "тупо в лоб" через case и паттерн матчинг:
```elixir
defmodule Bookshop.Solution1 do

  alias Bookshop.Model, as: M
  alias Bookshop.Controller, as: C

  @spec handle(map()) :: {:ok, M.Order.t()} | {:error, error}
  def handle(data) do
    case C.validate_incoming_data(data) do
      {:ok, data} ->
        do_next_validation() # ...
      {:error, error} -> {:error, error}
    end
  end
end
```

следующий шаг - 2я валидация
```elixir
  def handle(data) do
    case C.validate_incoming_data(data) do
      {:ok, data} ->
        case C.validate_user(data["user"]) do     # +
          {:ok, user} ->                          # +
            do_next() # ....                        +
          {:error, error} -> {:error, error}      # +
        end                                       # +

      {:error, error} -> {:error, error}
    end
  end
```

3й шаг валидации - глубина увеличивается
```elixir
  def handle(data) do
    case C.validate_incoming_data(data) do
      {:ok, data} ->
        case C.validate_user(data["user"]) do
          {:ok, user} ->
            case C.validate_address(data["address"]) do
              {:ok, address} ->
                {:ok, user, address} # do_next()...

              {:error, error} -> {:error, error}
            end

          {:error, error} -> {:error, error}
        end

      {:error, error} -> {:error, error}
    end
  end
```

до конца пока еще не реализовали но хорошо бы уже запустить и проверить
работает ли уже реализованный код или нет:

```elixir
iex> alias Bookshop, as: B
Bookshop
iex> data = Bookshop.test_data
%{
  "address" => "Freedom str 7/42 City Country",
  "books" => [
    %{
      "author" => "Scott Wlaschin",
      "title" => "Domain Modeling Made Functional"
    },
    %{
      "author" => "Mikito Takada",
      "title" => "Distributed systems for fun and profit"
    },
    %{"author" => "Marx, Valim, Tate", "title" => "Adopting Elixir"}
  ],
  "user" => "Attis"
}

iex> B.Solution1.handle(data)
{:ok, %Bookshop.Model.User{id: "Attis", name: "Attis"},
 %Bookshop.Model.Address{
   state: nil,
   city: nil,
   other: "Freedom str 7/42 City Country"
 }}

# просто "долбим" запросы и проверяем чтобы все три валидатора выдавали фейл:
iex> B.Solution1.handle(data)
{:error, :invalid_incoming_data}


iex> B.Solution1.handle(data)
{:error, :user_not_found}

iex> B.Solution1.handle(data)
{:error, :invalid_address}
```

> Валидация книг

```elixir
  def handle(data) do
    case C.validate_incoming_data(data) do
      {:ok, data} ->
        case C.validate_user(data["user"]) do
          {:ok, user} ->
            case C.validate_address(data["address"]) do
              {:ok, address} ->
                data["books"]                      # +
                |> Enum.map(&C.validate_book/1)    # +

              {:error, error} -> {:error, error}
            end

          {:error, error} -> {:error, error}
        end

      {:error, error} -> {:error, error}
    end
  end
```

смотрим в консоли что получаем
```elixir
iex> B.Solution1.handle(data)
[
  ok: %Bookshop.Model.Book{
    title: "Domain Modeling Made Functional",
    author: "Scott Wlaschin"
  },
  ok: %Bookshop.Model.Book{
    title: "Distributed systems for fun and profit",
    author: "Mikito Takada"
  },
  ok: %Bookshop.Model.Book{
    title: "Adopting Elixir",
    author: "Marx, Valim, Tate"
  }
]

# долбим до первого фейла:
iex> B.Solution1.handle(data)
[
  error: :book_not_found,     # <<<
  ok: %Bookshop.Model.Book{
    title: "Distributed systems for fun and profit",
    author: "Mikito Takada"
  },
  ok: %Bookshop.Model.Book{
    title: "Adopting Elixir",
    author: "Marx, Valim, Tate"
  }
]
```

но по нашей бизнес логике
если хотябы одна книга не найдена - нужно вернуть ошибку.
то есть валидация проходит успешна только когда все книги валидны

и в таких случаях может быть два подхода к реализации
- найти первую ошибку (книга не найдена) и вернуть только её
- пройтись по всем книгам и вернуть список всех ошибок списком.

```elixir
    data["books"]
    |> Enum.map(&C.validate_book/1)
    |> Enum.reduce({[], nil}, fn maybe_book, acc ->   #
      #            ^^^^^^^^^ intial_acc
      #             1    2                 3
        :do
    end)
```
- 1. список для валидных книг
- 2. флаг наличия ошибки
- 3. анонимная ф-я reducer


```elixir
    data["books"]
    |> Enum.map(&C.validate_book/1)
    |> Enum.reduce({[], nil}, fn
      maybe_book, acc ->
        :do
    end)
```

```elixir
    data["books"]
    |> Enum.map(&C.validate_book/1)
    |> Enum.reduce({[], nil}, fn
      maybe_book, {books, nil} ->
        :do
      _maybe_book, err -> # ...
        :error
    end)
```


```elixir
    data["books"]
    |> Enum.map(&C.validate_book/1)
    |> Enum.reduce({[], nil}, fn      # 1
      maybe_book, {books, nil} ->     # 1 2  maybe_book еще надо будет "раскрыть"
        :do                           # 1

      #_maybe_book, err ->            # 1
      _maybe_book, {_, err} = acc ->  # 1 3  - раскрыли
        acc                           # 1
      end
    )
```
- 1. Это анонимная функция с двумя closure(телами функций)
и это мы еще не разобрались с никгой maybe_book которая обёрнута в кортеж
(оценить это можно по выводу в консоли выше, который делали чуть раньше)

```elixir
    data["books"]
    |> Enum.map(&C.validate_book/1)
    |> Enum.reduce({[], nil}, fn
      # maybe_book, {books, nil} -> раскрываем в два варианта(тела ф-ий)
      {:ok, book}, {books, nil} ->     # + 1й вариант для maybe_book happy path
        {[book | books], nil}          # +

      {:error, error}, {books, nil} -> # + 1й вариант для maybe_book
        {books, {:error, error}}       # +

      _maybe_book, {_, err} = acc ->
        acc
      end
    )
```

```elixir
    data["books"]
    |> Enum.map(&C.validate_book/1)
    |> Enum.reduce({[], nil}, fn
      {:ok, book}, {books, nil} -> {[book | books], nil}          # 1 happy path

      {:error, error}, {books, nil} -> {books, {:error, error}}   # 2 add error

      _maybe_book, {_, err} = acc -> acc                          # 3 walk further
      end
    )
```
получаем что у нас есть редюсер описанный здесь анонимной функцией с 3мя телами
функций (closure)

- 3 у нас уже есть ошибка - просто идём дальше не проверяя все остальные книги
  передавая в аккумуляторе ошибку err

как релультат этого Enum.reduce(init_acc, reducer) будет кортеж в котором
- на первом месте будет массив книг {books, _}
- на втором месте будет ошибка(если она есть {books, err}


```elixir
iex> recompile
iex> B.Solution1.handle(data)
{[
   %Bookshop.Model.Book{title: "Adopting Elixir", author: "Marx, Valim, Tate"},
   %Bookshop.Model.Book{
     title: "Distributed systems for fun and profit",
     author: "Mikito Takada"
   },
   %Bookshop.Model.Book{
     title: "Domain Modeling Made Functional",
     author: "Scott Wlaschin"
   }
 ], nil}  # << случай когда нет ошибки все книги валидны  happy path


iex> B.Solution1.handle(data)
{[
   %Bookshop.Model.Book{
     title: "Distributed systems for fun and profit",
     author: "Mikito Takada"
   },
   %Bookshop.Model.Book{
     title: "Domain Modeling Made Functional",
     author: "Scott Wlaschin"
   }
 ], {:error, :book_not_found}}   # << одна книга не найден (валидация не прошла)
```
это ввывод нашего аккумулятора из Enum.Reduce -> `{[books], err}`

разбираемся дальше с этим аккумулятором (заказ или ошибка)

```elixir
    data["books"]
    |> Enum.map(&C.validate_book/1)
    |> Enum.reduce({[], nil}, fn
      {:ok, book}, {books, nil} -> {[book | books], nil}

      {:error, error}, {books, nil} -> {books, {:error, error}}

      _maybe_book, {_, _err} = acc -> acc
      end)
      # acc
    |> case do                         # +
      {books, nil} -> :create_order    # + happy path
      {_, error} -> error              # + validation error
    end                                # +

```
```elixir
iex(8)> B.Solution1.handle(data)
:create_order
...
iex(11)> B.Solution1.handle(data)
{:error, :book_not_found}
```
```elixir
  acc
    |> case do
      {books, nil} -> # :create_order    # + happy path
        {:ok, M.Order.create(user, address, books)}
      {_, error} -> error
    end
```


```elixir
iex> recompile

iex> B.Solution1.handle(data)
{:ok,
 %Bookshop.Model.Order{
   client: %Bookshop.Model.User{id: "Attis", name: "Attis"},
   address: %Bookshop.Model.Address{
     state: nil,
     city: nil,
     other: "Freedom str 7/42 City Country"
   },
   books: [
     %Bookshop.Model.Book{title: "Adopting Elixir", author: "Marx, Valim, Tate"},
     %Bookshop.Model.Book{
       title: "Distributed systems for fun and profit",
       author: "Mikito Takada"
     },
     %Bookshop.Model.Book{
       title: "Domain Modeling Made Functional",
       author: "Scott Wlaschin"
     }
   ]
 }}
i
```
попали на happy path -
видем здесь созданный заказ - Bookshop.Model.Order

если покидать еще запросы - будут вылезать и ошибки валидации
```elixir
iex> B.Solution1.handle(data)
{:error, :invalid_address}

iex> B.Solution1.handle(data)
{:error, :book_not_found}

iex> B.Solution1.handle(data)
{:error, :invalid_incoming_data}
```

### подводим итог сделанного

написали код очень далекий от идеального.
скорее всего Credo скажет на него - "перепеши это"
здесь
- 5 уровней вложенностей с case-оператором
- описано ветвление с 5ю вариантами ошибок и одним вариантом для happy path

проблемы такого кода:
- такой код тяжело читать и править и поддерживать:
- написали, и оно работает, а бизнес-логика не стоит на месте и вдруг наступает
  момент когда нужно добавить новые этапы валидации, а это значит такой код
  нужно будет модифицировать. То есть скажем у нас было 5 шагов валидации а
  теперь их 7... и эти 2 надо как-то вставить в этот развесистый код.
- либо надо просто поменять шаги валидации местами...
  в таком коде это не так то уж и просто! легко запутаться и словать код

Другими словами мы пришли к осознанию, что хотя такой код работает но...
никуда не годиться и нужно искать лучшее решение.



## 09_03 Решение 2. Каждый case в отдельной функции

Здесь мы переходим от такого solution-1:
```elixir
defmodule Bookshop.Solution1 do

  alias Bookshop.Model, as: M
  alias Bookshop.Controller, as: C

  @spec handle(map()) :: {:ok, M.Order.t()} | {:error, any()}
  def handle(data) do
    case C.validate_incoming_data(data) do
      {:ok, data} ->
        case C.validate_user(data["user"]) do
          {:ok, user} ->
            case C.validate_address(data["address"]) do
              {:ok, address} ->
                data["books"]
                |> Enum.map(&C.validate_book/1)
                |> Enum.reduce({[], nil}, fn
                  {:ok, book}, {books, nil} -> {[book | books], nil}

                  {:error, error}, {books, nil} -> {books, {:error, error}}

                  _maybe_book, {_, err} = acc -> acc
                  end)
                |> case do
                  {books, nil} ->
                    {:ok, M.Order.create(user, address, books)}
                  {_, error} -> error
                end

              {:error, error} -> {:error, error}
            end

          {:error, error} -> {:error, error}
        end

      {:error, error} -> {:error, error}
    end
  end
end
```

к более поддерживаемому решению.

- переход будем делать через рефакторинг.
- чтобы можно было делать рефакторинг нужно чтобы код был покрыт тестами
  без стестов скорее всего что-нить да сломаем

то есть все возможные варинаты ControlFlow т.е. все возможные ошибки и happy path
должны быть покрыты тестами.
проблема. ф-и валидации работают рандомно. (через rand_success)
а он всегда выдаёт непредсказуемые результаты.
выход - делать детерминированную валидацию:
 - то есть захардкодим валидные и не валидные значения для сущностей
   юзер, адрес, книга.
   (сделаем валидацию чуть более приблеженную к реальности)

затем покроим всё solution-1 тестами и тогда уже можно будет
переходить от solution-1 к solution-2 через пошаговый рефакторинг.

Нам нужны будут два вида тестов:
- юнит тесты, на все наши функции валидации входных данных
  - на каждую ф-ю валидации нужно подать успешный вариант и убедиться в :ok
  - и еще фейловый вариант который возращает :error
- интеграционные тесты на ф-ю Controller.handle
  - в эту ф-ю будем подавать всю структуру data в разных вариантах и убеждаться
  что возращается нужная ветка. - либо happy path либо конкретная ошибка.

вот и получаем что
- нужно как минимум два модуля с тестами
  - один с юнит тестами на ф-и валидации
  - второй с интеграционными тестами на solution

да можно было бы юнит-тесты на ф-и валидации в Controller и не писать
дескоть "для сокращения времени". Но на деле всё равно начинать от юнит-тестов
будет удобнее, т.к. куски кода и данных из юнит тестов потом будем использовать
в интеграционных тестах для формирования data в ф-ю handle


### изучаем сгенерированные тесты в нашем проекте
```sh
tree test

test
├── bookshop_test.exs
└── test_helper.exs
```

test/test_helper.exs
```elixir
ExUnit.start()
```
этот хэлпер просто запускает тестовый фреймворк `ExUnit`

заглушка теста для главного модуля (будет падать)
```elixir
defmodule BookshopTest do
  use ExUnit.Case
  doctest Bookshop    # тесты на документацию, это другая тема. пока убираем

  test "greets the world" do
    assert Bookshop.hello() == :world # Надо исправлять чтобы не падало
  end
end
```

нам нужны solution_tesst.exs и controller_test.exs


```elixir
defmodule BookshopTest do
  use ExUnit.Case
  doctest Bookshop    # тесты на документацию, это другая тема. пока убираем

  test "greets the world" do
    assert Bookshop.hello() == :world
  end
end
```

- Bookshop.test_data() - возращает Map с тестовыми данными, которые по сути нам
нужны будут везде - во всех тестах и в юнит и в интеграционных.

вообще есть такие либы, для генерации такого рода объектов-сэмплов, которые
нужны для тестов и которые переиспользуются в нескольких местах(тестов)

пока для простоты можем просто сделать отдельный модуль и разместить в него
функции для возрата нужных нам значений.


./test/test_data.ex
```elixir
defmodule TestData do
  def valid_data() do     # просто копия из bookshop.ex
    %{
      "user" => "Attis",
      "address" => "Freedom str 7/42 City Country",
      "books" => [
        %{
          "title" => "Domain Modeling Made Functional",
          "author" => "Scott Wlaschin" },
        %{
          "title" => "Distributed systems for fun and profit",
          "author" => "Mikito Takada"},
        %{
          "title" => "Adopting Elixir",
          "author" => "Marx, Valim, Tate"
        },
      ]
    }
  end
end
```

> обрати внимание на расширение ex в test_data.ex
данный файл test_data.ex будем переиспользовать в разных нестах поэтому нужно
чтобы он компирировался. Сами же тесты они exs - скрипты, которые не будут
компилироваться, а сразу интерпретироваться.

теперь чтобы этот модуль был доступен в тестах его нужно явно "подключить"

сделать это по-быстрому можно через тест-хэлпер:

./test/test_helper.exs
```elixir
ExUnit.start()
Code.require_file("test_data.ex", __DIR__)   # <<< подключение модуля
```

но более правильный способ - переместить этот модуль в каталог `test/support`
и прописать дополнительные пути компиляции elixirc_paths в mix.exs так чтобы
этот модуль компилировался и был доступен в Mix.evn == :test (в тестах)

mix.exs:
```elixir
defmodule Bookshop.MixProject do
  use Mix.Project

  def project do
    [
      app: :bookshop,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env)               # +
    ]
  end

  # ...
  defp elixirc_paths(:test), do: ["lib", "test/support"]  # +
  defp elixirc_paths(_), do: ["lib"]                      # +
end
```
и при этом сам ex модуль помещаем в каталог test/support:
```sh
tree test
test
├── bookshop_test.exs
├── support
│   └── test_data.ex     # <<<
└── test_helper.exs
```

и уже в конфиге прописываем новый путь для компиляции:
```
  elixirc_path: elixirc_paths(Mix.env)
  ...

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
```
Mix.evn - возращает атом соответствующий текущему окружению :dev :test :prod
а внизу описываем clause(тела функций) elixirc_paths где и задаём дополнительный
каталог test/support


и теперь можно использовать
(пример в уже созданном(mix new...) тестовом модуле:

```elixir
defmodule BookshopTest do
  use ExUnit.Case

  test "data" do
    assert Bookshop.test_data() == TestData.valid_data()
  end
end
```

> как создать тестовый модуль для тестируемого модуля
создаём тестовый модуль с таким же именем как у тестируемого, в test каталоге
и добавляя к имени суффикс Test


первый тест "happy path" используя сэмплы из модуля TestData

./test/controller_test.exs
```elixir
defmodule Bookshop.ControllerTest do
  #                          ^^^^
  use ExUnit.Case
  alias Bookshop.Controller, as: C

  test "validate incoming data" do # (1)
    valid_data = TestData.valid_data()
    assert C.validate_incoming_data(valid_data) == {:ok, valid_data}  # (2)
  end
end
```
- 1. test - это макрос принимающий на вход название теста и его "тело"
  с разными утверждениями(assert-ами)
- 2. assert(утверждение) для тестирования первой ветки кода в ф-и
  validate_incoming_data

Есть разные подхоты к тому, как писать ассерты:
- один ассерт на одну тестовую функцию(тест)
- все возможные проверки(ассерты) на одну проверяемую функцию.
  когда в одной тестовой ф-и описываем через ассерты все ветки кода в
  проверяемой функции:

```elixir
defmodule Bookshop.ControllerTest do
  use ExUnit.Case
  alias Bookshop.Controller, as: C

  test "validate incoming data" do
    valid_data = TestData.valid_data()
    assert C.validate_incoming_data(valid_data) == {:ok, valid_data}

    # ассерт для второй ветки кода, - кейс с ошибкой
    invalid_data = TestData.invalid_data()
    assert C.validate_incoming_data(invalid_data) == {:error, :invalid_incoming_data}
  end
end
```
теперь нам нужен сэмпл TestData.invalid_data():
```elixir
defmodule TestData do

  def valid_data() do
    # ...
  end

  def invalid_data() do  # +
    %{
      "guest" => "Attis",
      "address" => "Freedom str 7/42 City Country"
    }
  end
end
```

но так как пока у нас валидация работает на случаных числах то тесты чаще
будут падать на ассертах, нежели проходить
```elixir
  def validate_incoming_data(data) do
    if rand_success() do                 # 90% успеха и 10% неудач
      {:ok, data}
    else
      {:error, :invalid_incoming_data}
    end
  end
```

запускаем тесты
```sh
mix test
```
т.к. валидация пока число на рандоме, чаще тесты будут падать.
```sh
Running ExUnit with seed: 65023, max_cases: 8

.

  1) test Controller validate incoming data (Bookshop.ControllerTest)
     test/controller_test.exs:8
     Assertion with == failed
     code:  assert C.validate_incoming_data(invalid_data) == {:error, :invalid_incoming_data}
     left:  {:ok, %{"address" => "Freedom str 7/42 City Country", "admin" => "Attis"}}
     right: {:error, :invalid_incoming_data}
     stacktrace:
       test/controller_test.exs:13: (test)


Finished in 0.03 seconds (0.00s async, 0.03s sync)
2 tests, 1 failure
```

но всё же можно подловить момент когда для невалидного значения
валидация зафейлиться(10%) - тогда тест пройдёт
```sh
mix test
Running ExUnit with seed: 528467, max_cases: 8

..
Finished in 0.01 seconds (0.00s async, 0.01s sync)
2 tests, 0 failures
```

> пишем тесты на все остальные ф-и валидации

```elixir
defmodule Bookshop.ControllerTest do
  use ExUnit.Case
  alias Bookshop.Controller, as: C
  alias Bookshop.Model, as: M


  test "validate incoming data" do
    valid_data = TestData.valid_data()
    assert C.validate_incoming_data(valid_data) == {:ok, valid_data}

    invalid_data = TestData.invalid_data()
    assert C.validate_incoming_data(invalid_data) == {:error, :invalid_incoming_data}
  end

  test "validate user" do
    assert C.validate_user("Joe") == {:ok, %M.User{id: "Joe", name: "Joe"}}
    assert C.validate_user("Nemean") == {:error, :user_not_found}
  end

  test "validate address" do
    assert C.validate_address("City State") == {
        :ok,
        %M.Address{state: nil, city: nil, other: "City State"}
    }
    assert C.validate_address("42") == {:error, :invalid_address}
  end

  test "validate booke" do
    valid_book = TestData.valid_book()
    assert C.validate_address(valid_book) == {
        :ok,
        %M.Book{
          title: valid_book["tile"],
          author: valid_book["author"]
        }
    }

    invalid_book = TestData.invalid_book()
    assert C.validate_address(invalid_book) == {:error, :book_not_found}
  end
end
```

```elixir
defmodule TestData
  # ...
  def valid_book do
    %{
      "title" => "Adopting Elixir",
      "author" => "Marx, Valim, Tate"
    }
  end

  # книга которой нет на складе - поэтому она считается не валидной
  def invalid_book do
    %{
      "title" => "Functional Web Development with Elixir, OTP and Phoenix",
      "author" => "Lance Halvorsen"
    }
  end
```
тут сэмплы скорее про то, что есть ли такая книга на сладе, а не про то
все ли поля обьекта пришли или не все.


переписываем
```elixir
defmodule Controller do
  def validate_incoming_data(data) do
    if rand_success() do
      {:ok, data}
    else
      {:error, :invalid_incoming_data}
    end
  end
```

просто через паттер матчинг проверяем прямо в сигнатуре функции что все
нужные ключи есть.
```elixir
  @spec validate_incoming_data(map()) :: {:ok, map()} | {:error, :invalid_incoming_data}
  def validate_incoming_data(%{"user" => _, "address" => _, "books" = _} = data) do
    {:ok, data}
  end
  def validate_incoming_data(_) do
    {:error, :invalid_incoming_data}
  end
```
здесь идея валидации в том, чтобы проверять наличеи основных ключей, но не
проверяя всё. Обычно для валидации(проверки) всех уровней вложенности - есть
спец либы, и руками это никто не проверят - это слишком муторно и долго.
Такие вещи не валидируют руками - пользуются специальными библиотеками, которые
умеют валидировать данные по заданной схеме.


```elixir
  # Emulation of the check in the database
  @existing_users ["Joe", "Alice", "Bob" ]

  # ...

  def validate_user(name) do
    if name in @existing_users do
      {:ok, %M.User{id: name, name: name}}
    else
      {:error, :user_not_found}
    end
  end
```

по аналогии изменяем все остальные валидаторы
```elixir
defmodule Bookshop.Controller do
  alias Bookshop.Model, as: M

  # ..

  def validate_address(data) do
    if String.length(data) > 5 do
      {:ok, %M.Address{other: data}}
    else
      {:error, :invalid_address}
    end
  end

  @existing_authors ["Scott Wlaschin", "Mikito Takada", "Marx, Valim, Tate" ]

  def validate_book(%{"author" => author} = data) do
    if author in @existing_authors do
      {:ok, %M.Book{title: data["title"], author: data["author"]}}
    else
      {:error, :book_not_found}
    end
  end

  # больше эта функция не нужна
  # def rand_success() do
  #   Enum.random(1..10) > 1
  # end

```

```sh
mix test
Running ExUnit with seed: 599907, max_cases: 8

.....
Finished in 0.03 seconds (0.00s async, 0.03s sync)
5 tests, 0 failures
```


#### интеграционные тесты для solution-1

test/solution_test.exs:
```elixir
defmodule Bookshop.SolutionTest do
  use ExUnit.Case
  # import Solution1
  alias Bookshop.Solution1, as: S

  test "todo" do
    assert 1 + 1 == 2
  end

end
```

модуль SolutionTest будет один на все наши решения.

пишем базовый сценарий.(happy path)
- ф-я hanlde принимает валидные данные (data) и должна вернуть валидный Order

```elixir
defmodule Bookshop.SolutionTest do
  use ExUnit.Case
  alias Bookshop.Model, as: M
  alias Bookshop.Solution1, as: S

  test "create order" do
    valid_data = TestData.valid_data()
    assert S.handle(valid_data) == {:ok, %M.Order{}}
  end

end
```

```elixir
  test "create order" do
    valid_data = TestData.valid_data()
    assert S.handle(valid_data) == {:ok, %M.Order{
      client: %M.User{id: "Joe", name: "Joe"},
      address: %M.Address{
        state: nil,
        city: nil,
        other: "Freedom str 7/42 City State"
      },
      books: [
        %M.Book{title: "Domain Modeling Made Functional", author: "Scott Wlaschin"},
        %M.Book{title: "Distributed systems for fun and profit", author: "Mikito Takada"},
        %M.Book{title: "Adopting Elixir", author: "Marx, Valim, Tate"},
      ],
    }}
  end
```

> о порядке книг в тесте, проблемы матчинга элементов в списке
запускаем тесты и сталкиваемся с проблема порядка книг

как обычно это решают
- если список элементов приходит из неких внешних источников, которые не
  гарантируют порядок, то обычно такой список до ассерта сортируют чтобы
  всегда ганартировать нужный порядок, иначе тест будет падать
- в нашем случае порядок детерминирован(один и тот же, и не меняется)
  поэтому можно просто статически изменить порядок на нужный


дописываем все возможные ветвления в Controller.handle

```elixir
  test "invalid incoming data" do
    valid_data = TestData.invalid_data()

    assert S.handle(valid_data) == {:error, :invalid_incoming_data}
  end

  test "invalid user" do
    data =
      TestData.valid_data()
      |> Map.put("user", "Nemean")

    assert S.handle(data) == {:error, :user_not_found}
  end

  test "invalid address" do
    data =
      TestData.valid_data()
      |> Map.put("address", "wrong")

    assert S.handle(data) == {:error, :invalid_address}
  end

  # здесь берём книгу "которой нет"(невалидную) и добавляем в начало списка книг
  test "invalid book" do
    invalid_book = TestData.invalid_book()

    data =
      TestData.valid_data()
      |> update_in(["books"], fn books -> [invalid_book | books] end)

    assert S.handle(data) == {:error, :book_not_found}
  end
```

проверяем - все тесты проходят - можно начинать рефакториг
```sh
mix test
Running ExUnit with seed: 843639, max_cases: 8

..........
Finished in 0.04 seconds (0.00s async, 0.04s sync)
10 tests, 0 failures
```

итак тесты готовы, покрывают все возможные случа а значит подготовка закончена


#### Solution-2 начало реализации

lib/solution2.ex
```elixir
defmodule Bookshop.Solution2 do
  alias Bookshop.Model, as: M
  alias Bookshop.Controller, as: C

  @spec handle(map()) :: {:ok, M.Order.t()} | {:error, any()}
  def handle(data) do
    # тот же код что в Solution1
  end
end
```

```elixir
defmodule Bookshop.SolutionTest do
  use ExUnit.Case
  alias Bookshop.Model, as: M
  # alias Bookshop.Solution1, as: S
  alias Bookshop.Solution2, as: S     # (+)

  # сами тесты без изменений
```

обычно считается примемлимым делать уровень вложенности до 2х
у нас же здесь, вложенность 5.

lib/solution2.ex
```elixir
  def handle(data) do
    case C.validate_incoming_data(data) do
      {:ok, data} ->
        case C.validate_user(data["user"]) do
          {:ok, user} ->
            case C.validate_address(data["address"]) do
              {:ok, address} ->
                data["books"]
                |> Enum.map(&C.validate_book/1)
                |> Enum.reduce({[], nil}, fn
                  {:ok, book}, {books, nil} -> {[book | books], nil}
                  {:error, error}, {books, nil} -> {books, {:error, error}}
                  _maybe_book, acc -> acc
                end)
                |> case do
                  {books, nil} ->
                    {:ok, M.Order.create(user, address, books)}

                  {_, error} ->
                    error
                end

              {:error, error} ->
                {:error, error}
            end

          {:error, error} ->
            {:error, error}
        end

      {:error, error} ->
        {:error, error}
    end
  end
```

- некоторые могут смотреть коса на код уже с вложеностью 2 и больше.
- и даже линтер Credo обраружив код в вложенностью 3 начнёт кидать ворнинги
  что-то вроде перепеши "это", продлагая вынести вложенные case в отдельные ф-и
  чтобы улучшить читаемость кода.

первый кусок кода для выноса в отдельную ф-ю
```elixir
                data["books"]
                |> Enum.map(&C.validate_book/1)
                |> Enum.reduce({[], nil}, fn
                  {:ok, book}, {books, nil} -> {[book | books], nil}
                  {:error, error}, {books, nil} -> {books, {:error, error}}
                  _maybe_book, acc -> acc
                end)
```


```elixir
  def handle(data) do
    case C.validate_incoming_data(data) do
      {:ok, data} ->
        case C.validate_user(data["user"]) do
          {:ok, user} ->
            case C.validate_address(data["address"]) do
              {:ok, address} ->
                handle_books(data["books"])  # +++
                |> case do
                  {:ok, books} -> {:ok, M.Order.create(user, address, books)}
                  error -> error
                end

              {:error, error} ->
                {:error, error}
            end

          {:error, error} ->
            {:error, error}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  # extracted code:
  def handle_books(books) do
    books # data["books"]
    |> Enum.map(&C.validate_book/1)
    |> Enum.reduce({[], nil}, fn
      {:ok, book}, {books, nil} -> {[book | books], nil}
      {:error, error}, {books, nil} -> {books, {:error, error}}
      _maybe_book, acc -> acc
    end)
    |> case do
      {books, nil} -> {:ok, books}
      {_, error} -> error
    end
  end
```

```elixir
                handle_books(data["books"])
                |> case do
                  {:ok, books} -> {:ok, M.Order.create(user, address, books)}
                  error -> error
                end
```
упрощаем до
```elixir
                case handle_books(data["books"]) do
                  {:ok, books} -> {:ok, M.Order.create(user, address, books)}
                  error -> error
                end
```

теперь уровень вложенности в Controller.handle меньше на 1
запускаем тесты и проверям что ничего не сломалось и всё работает как надо.


следущий шаг - уменьшаем вложеность дальше

смотрим на код и думаем как уменьшить вложеность еще на 1
```elixir
                case handle_books(data["books"]) do
                  {:ok, books} -> {:ok, M.Order.create(user, address, books)}
                  error -> error
                end
```
handle_books - вернёт при успехе список книг,..
а чтобы создать Order нам нужен набор неких данных. значит...

приходим к пониманию того, что у нас есть значения (user, address, books)
можно их еще назвать "промежуточные результаты(значения)", которые будут нужны
дальше для создания Order:

```elixir
        case C.validate_user(data["user"]) do
          {:ok, user} ->
          #     ^(1a) -------------------------------------.
            case C.validate_address(data["address"]) do #  |
              {:ok, address} ->                         #  v
              #     ^(2a) ---------------------------------------.
                case handle_books(data["books"]) do #            v
                  {:ok, books} -> {:ok, M.Order.create(  user, address, books)}
                  #     ^(3a)                            ^(1b)  ^(2b)     ^(3b)
                  #        `----------------------------------------------'
                  error -> error
                end

              {:error, error} ->
                {:error, error}
            end

          #....
        end

```
- 1a значение user будет нужено в Oreder.create (1b)
- 2a address нужено в 2b
- 3а books нужено в 3b

то есть если дальше выносить код из case в отдельные функции то надо как-то
прокидывать эти промежуточные значения, например как аргументы функций
и да, можно каждое промежуточное значение прокидывать как отдельный аргумент
функции, но зная что проект будет развиваться и что шаги валидации, а значит и
кол-во таких промежуточных значений может меняться, лучше выделить отдельную
переменную state накапливать всё нужное в нём и дальше уже передавать это в
функцию создающую Order.

теперь будем выносить вот этот код в отдельную функцию
```elixir
  def handle(data) do
    case C.validate_incoming_data(data) do
      {:ok, data} ->
        case C.validate_user(data["user"]) do
          {:ok, user} ->
            # --------------- >>>  уже здесь нам нужет будет state
            case C.validate_address(data["address"]) do
              {:ok, address} ->
                case handle_books(data["books"]) do
                  {:ok, books} -> {:ok, M.Order.create(user, address, books)}
                  error -> error
                end

              {:error, error} ->
                {:error, error}
            end
            # --------------- <<<

          {:error, error} ->
            {:error, error}
        end

      {:error, error} ->
        {:error, error}
    end
  end
```

```elixir
  def handle(data) do
    case C.validate_incoming_data(data) do
      {:ok, data} ->
        case C.validate_user(data["user"]) do
          {:ok, user} ->
            case C.validate_address(data["address"]) do
              {:ok, address} ->
                state = %{user: user, address: address}   # +
                create_order(data["books"], state)        # +

              {:error, error} ->
                {:error, error}
            end

          {:error, error} ->
            {:error, error}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  # def handle_books(books, state) do  # -
  def create_order(books, state) do    # +
    books # data["books"]
    |> Enum.map(&C.validate_book/1)
    |> Enum.reduce({[], nil}, fn
      {:ok, book}, {books, nil} -> {[book | books], nil}
      {:error, error}, {books, nil} -> {books, {:error, error}}
      _maybe_book, acc -> acc
    end)
    |> case do
      # {books, nil} -> {:ok, books}
      {books, nil} -> {:ok, M.Order.create(state.user, state.address, books)} # +
      {_, error} -> error
    end
  end
```

> handle_address

унифицируем извлечение промежуточных значений, будем везде передавать (Map)data
```elixir
  def handle(data) do
    case C.validate_incoming_data(data) do
      {:ok, data} ->
        case C.validate_user(data["user"]) do
          {:ok, user} ->
            case C.validate_address(data["address"]) do      # Этот код будем
              {:ok, address} ->                              # выносить в ф-ю
                state = %{user: user, address: address}
                create_order(data, state)
                #            ^^^^
                #...
            end
            #...
        end
        #...
    end
  end

  def handle_address(data, state) do
    #...             ^^^^ Map
  end

  def create_order(%{"books" => books}, state) do
  #                ^^^^^^^^^^^^^^^^^^^
    books # data["books"]
    |> Enum.map(&C.validate_book/1)
    |> Enum.reduce({[], nil}, fn
      {:ok, book}, {books, nil} -> {[book | books], nil}
      {:error, error}, {books, nil} -> {books, {:error, error}}
      _maybe_book, acc -> acc
    end)
    |> case do
      # {books, nil} -> {:ok, books}
      {books, nil} -> {:ok, M.Order.create(state.user, state.address, books)} # +
      {_, error} -> error
    end
  end
```

приходим к такому коду(убрали еще один уровень вложенности)

```elixir
  def handle(data) do
    case C.validate_incoming_data(data) do
      {:ok, data} ->
        case C.validate_user(data["user"]) do
          {:ok, user} ->
            state = %{user: user}         # +
            handle_address(data, state)   # +

          {:error, error} ->
            {:error, error}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  def handle_address(data, state) do
    case C.validate_address(data["address"]) do
      {:ok, address} ->
        state = Map.put(state, :address, address)
        create_order(data, state)

      {:error, error} ->
        {:error, error}
    end
  end
```

проверяем(mix test) - работает. идём дальше.

#### выносим handle_user

```elixir
  def handle(data) do
    case C.validate_incoming_data(data) do
      {:ok, data} ->
        state = %{}                # +
        handle_user(data, state)   # +

      {:error, error} ->
        {:error, error}
    end
  end

  def handle_user(data, state) do
    case C.validate_user(data["user"]) do
      {:ok, user} ->
        state = Map.put(state, :user, user)
        handle_address(data, state)

      {:error, error} ->
        {:error, error}
    end
  end

  # ....
```
проверяем - работает
теперь у нас во всех функция один уровень вложенности:
```elixir
  @spec handle(map()) :: {:ok, M.Order.t()} | {:error, any()}
  def handle(data) do
    case C.validate_incoming_data(data) do
      {:ok, data} ->
        state = %{}
        handle_user(data, state)

      {:error, error} ->
        {:error, error}
    end
  end

  def handle_user(data, state) do
    case C.validate_user(data["user"]) do
      {:ok, user} ->
        state = Map.put(state, :user, user)
        handle_address(data, state)

      {:error, error} ->
        {:error, error}
    end
  end

  def handle_address(data, state) do
    case C.validate_address(data["address"]) do
      {:ok, address} ->
        state = Map.put(state, :address, address)
        create_order(data, state)

      {:error, error} ->
        {:error, error}
    end
  end

  # handle_books + create_order
  def create_order(%{"books" => books}, state) do
    books # data["books"]
    |> Enum.map(&C.validate_book/1)
    |> Enum.reduce({[], nil}, fn
      {:ok, book}, {books, nil} -> {[book | books], nil}
      {:error, error}, {books, nil} -> {books, {:error, error}}
      _maybe_book, acc -> acc
    end)
    |> case do
      # {books, nil} -> {:ok, books}
      {books, nil} -> {:ok, M.Order.create(state.user, state.address, books)} # +
      {_, error} -> error
    end
  end
```
как результат у нас получилось 4 функции по цепочке вызывающие друг друга
своего рода матрёшка.

теперь чётко видно "что за чем идёт" - на каждом шаге
то есть теперь проследить цепочку вызова функций намного проще и понятнее
- убрали проблему большой вложенности case-блоков
- добавить новые шаги теперь намного легче - просто дописать новый handle_*
  и добавить его в нужное мечто цепочки
- теперь можно "шаги" менять местами например сначала валидировать адрес затем
  пользователя

а значит это решение уже лучше 1го, хотя и не идеально:
- много одинакового, повторяющегося кода ("мокрый код")
```elixir
  def handle_user(data, state) do
    case C.validate_user(data["user"]) do
      {:ok, user} ->                               # <
        state = Map.put(state, :user, user)        # <
        handle_address(data, state)

      {:error, error} ->                           # <
        {:error, error}                            # <
    end
  end

  def handle_address(data, state) do
    case C.validate_address(data["address"]) do
      {:ok, address} ->                             # <
        state = Map.put(state, :address, address)   # <
        create_order(data, state)

      {:error, error} ->                            # <
        {:error, error}                             # <
    end
  end
```
если присмотреться то можно увидеть паттерн одинаковых действий:
- case
- вызов функции
- при успехе идём дальше - вызов следующей ф-и в цепочке
- при фейле - сразу вернуть ошибку

другими словами напрашивается сделать некую абстракцию для этого паттерна.
и если сделать такую абстракцию то можно будет более изящно и кратко выражать
тоже самое, без дублирования одного и того же кода
чтобы укоротить его.



## 09_04 Решение 3. Использование исключений

на начало работ у нас есть:
- валидирующие функции в Controller возращающие {:ok, data} или {:error, err}
- solution2.ex использующий эти функции выстраивая цепочку вызовов

Будем делать логику "на исключениях" (И именно так во многи ЯП и делают)
- нужно переписать валидирующие ф-и так, чтобы они бросали исключения
- создать свои пользовательские исключения (4 штуки)

> где размещать свои кастомные исключения
- отдельный модуль Errors

lib/errors.ex:
```elixir
defmodule Bookshop.Errors do

  defmodule InvalidIncomingData do
    defexception []

    @impl true
    def exception(_), do: %InvalidIncomingData{}

    @impl true
    def message(_ex), do: "InvalidIncomingData"
  end

  defmodule UserNotFound do
    defexception [:name]

    @impl true
    def exception(name), do: %UserNotFound{name: name}

    @impl true
    def message(ex), do: "UserNotFound #{ex.name}"
  end

  defmodule InvalidAddress do
    defexception [:data]

    @impl true
    def exception(data), do: %InvalidAddress{data: data}

    @impl true
    def message(ex), do: "InvalidAddress #{ex.data}"
  end

  defmodule BookNotFound do
    defexception [:title, :author]

    @impl true
    def exception({title, author}), do: %BookNotFound{title: title, author: author}

    @impl true
    def message(ex), do: "BookNotFound #{ex.title} #{ex.author}"
  end

end
```

```sh
iex -S mix
```
проверяю киюдаются ли исключения
```elixir
iex> raise Bookshop.Errors.InvalidIncomingData
** (Bookshop.Errors.InvalidIncomingData) InvalidIncomingData

iex> raise Bookshop.Errors.InvalidAddress, "address"
** (Bookshop.Errors.InvalidAddress) InvalidAddress address

iex> raise Bookshop.Errors.UserNotFound, "username"
** (Bookshop.Errors.UserNotFound) UserNotFound username

iex> raise Bookshop.Errors.BookNotFound, {"title", "author"}
** (Bookshop.Errors.BookNotFound) BookNotFound title author
```

#### реализуем второй набор функций для работы с нашими исключениями

```elixir
  # ...
  alias Bookshop.Errors, as: E

  # старая для кототорой пишем новую
  @spec validate_incoming_data(map()) :: {:ok, map()} | {:error, :invalid_incoming_data}
  def validate_incoming_data(%{"user" => _, "address" => _, "books" => _} = data) do
    {:ok, data}
  end

  def validate_incoming_data(_) do
    {:error, :invalid_incoming_data}
  end


  # новая:
  @spec validate_incoming_data!(map()) :: map()
  def validate_incoming_data!(%{"user" => _, "address" => _, "books" => _} = data) do
    data
  end

  def validate_incoming_data!(_) do
    raise E.InvalidIncomingData()
  end
```

Остальные:
```elixir
  @spec validate_user!(name :: String.t()) :: User.t()
  def validate_user!(name) do
    if name in @existing_users do
      %M.User{id: name, name: name}
    else
      raise E.UserNotFound, name
    end
  end

  @spec validate_address!(String.t()) ::  Address.t()
  def validate_address!(data) do
    if String.length(data) > 5 do
      %M.Address{other: data}
    else
      raise E.InvalidAddress, data
    end
  end

  @spec validate_book!(map()) :: Book.t()
  def validate_book!(%{"author" => author} = data) do
    if author in @existing_authors do
      %M.Book{title: data["title"], author: data["author"]}
    else
      raise E.BookNotFound, {data["title"], data["author"]}
    end
  end
```

проверяем работу ф-ий через консоль
```sh
iex -S mix
```

```elixir
# то, что будем прокидывать в Controller.handle
iex> data = Bookshop.test_data
%{
  "address" => "Freedom str 7/42 City State",
  "books" => [
    %{
      "author" => "Scott Wlaschin",
      "title" => "Domain Modeling Made Functional"
    },
    %{
      "author" => "Mikito Takada",
      "title" => "Distributed systems for fun and profit"
    },
    %{"author" => "Marx, Valim, Tate", "title" => "Adopting Elixir"}
  ],
  "user" => "Joe"
}

iex> Bookshop.Controller.validate_incoming_data!(data)
%{
  "address" => "Freedom str 7/42 City State",
  "books" => [
    %{
      "author" => "Scott Wlaschin",
      "title" => "Domain Modeling Made Functional"
    },
    %{
      "author" => "Mikito Takada",
      "title" => "Distributed systems for fun and profit"
    },
    %{"author" => "Marx, Valim, Tate", "title" => "Adopting Elixir"}
  ],
  "user" => "Joe"
}

# убираем к-в пару:
iex> data2 = Map.drop(data, ["books"])
%{"address" => "Freedom str 7/42 City State", "user" => "Joe"}

iex> Bookshop.Controller.validate_incoming_data!(data2)
** (Bookshop.Errors.InvalidIncomingData) InvalidIncomingData
    (bookshop 0.1.0) lib/controller.ex:57: Bookshop.Controller.validate_incoming_data!/1
    iex:4: (file)
```
работает. кидает исключение на не валидные данные


#### пишем solution-3 на новых функциях валидации с исключениями

lib/solution3.ex
```elixir
defmodule Bookshop.Solution3 do
  alias Bookshop.Model, as: M
  alias Bookshop.Controller, as: C

  @spec handle(map()) :: {:ok, M.Order.t()} | {:error, any()}
  def handle(data) do
    # ... здесь нужно вызвать "цепочку" ф-ий валидации и собрать Order
    # через try/rescue
  end
```


после валидации у нас будут все нужные значения для создания Order
```elixir
  def handle(data) do
    try do
      data = C.validate_incoming_data!(data)
      # Извлекаем ключи из Map
      %{
        "user" = user,
        "address" = address,
        "books" = books,
      } = data
      # ... собрать Order...

    rescue # будет перехватывать только Эликсировские исключения
      # перехватыем только наши доменные исключения,
      e in [E.InvalidIncomingData, E.UserNotFound, E.InvalidAddress, E.BookNotFound] ->
        {:error, Exception.message(e)}
    end
  end
```

вот уже готовое решение-3
```elixir
  @spec handle(map()) :: {:ok, M.Order.t()} | {:error, any()}
  def handle(data) do
    try do
      data = C.validate_incoming_data!(data)
      %{
        "user" => username,
        "address" => address_str,
        "books" => books_data,
      } = data
      cat = C.validate_user!(username)
      #                    ^ with exception
      address = C.validate_address!(address_str)
      #                           ^
      books =
        Enum.map(books_data, fn one_book_data ->
          C.validate_book!(one_book_data )
          #              ^
        end)
      order = M.Order.create(cat, address, books)
      {:ok, order}
    rescue
      e in [E.InvalidIncomingData, E.UserNotFound, E.InvalidAddress, E.BookNotFound] ->
        {:error, Exception.message(e)}
    end
  end
```

компилируем и проверяем работает ли?
```sh
mix compile && ies -S mix
```

```elixir
iex> data = Bookshop.test_data
%{
  "address" => "Freedom str 7/42 City State",
  "books" => [
    %{
      "author" => "Scott Wlaschin",
      "title" => "Domain Modeling Made Functional"
    },
    %{
      "author" => "Mikito Takada",
      "title" => "Distributed systems for fun and profit"
    },
    %{"author" => "Marx, Valim, Tate", "title" => "Adopting Elixir"}
  ],
  "user" => "Joe"
}

iex> Bookshop.Solution3.handle(data)
{:ok,
 %Bookshop.Model.Order{
   client: %Bookshop.Model.User{id: "Joe", name: "Joe"},
   address: %Bookshop.Model.Address{
     state: nil,
     city: nil,
     other: "Freedom str 7/42 City State"
   },
   books: [
     %Bookshop.Model.Book{
       title: "Domain Modeling Made Functional",
       author: "Scott Wlaschin"
     },
     %Bookshop.Model.Book{
       title: "Distributed systems for fun and profit",
       author: "Mikito Takada"
     },
     %Bookshop.Model.Book{title: "Adopting Elixir", author: "Marx, Valim, Tate"}
   ]
}}
```
работает.

проверяем тесты
```sh
mix test
```

```elixir
Compiling 4 files (.ex)
Generated bookshop app
Running ExUnit with seed: 980081, max_cases: 8

.....

  1) test invalid incoming data (Bookshop.SolutionTest)
     test/solution_test.exs:31
     Assertion with == failed
     code:  assert S.handle(valid_data) == {:error, :invalid_incoming_data}
     left:  {:error, "InvalidIncomingData"}
     right: {:error, :invalid_incoming_data}
     stacktrace:
       test/solution_test.exs:34: (test)
...

  3) test create order (Bookshop.SolutionTest)
     test/solution_test.exs:8
  ...

Finished in 0.02 seconds (0.00s async, 0.02s sync)
10 tests, 5 failures
```


### Разбираемся с тестами по порядку

способ запустить один тест из тестового модуля

'test create order'
```sh
mix test test/solution_test.exs:8
```

```html
Compiling 1 file (.ex)
Generated bookshop app
Running ExUnit with seed: 149533, max_cases: 8
Excluding tags: [:test]
Including tags: [location: {"test/solution_test.exs", 8}]

  1) test create order (Bookshop.SolutionTest)
     test/solution_test.exs:8
     Assertion with == failed
     code:  assert S.handle(valid_data) ==
              {:ok,
               %M.Order{
                 client: %M.User{id: "Joe", name: "Joe"},
                 address: %M.Address{state: nil, city: nil, other: "Freedom str 7/42 City State"},
                 books: [
                   %M.Book{title: "Adopting Elixir", author: "Marx, Valim, Tate"},
                   %M.Book{title: "Distributed systems for fun and profit", author: "Mikito Takada"},
                   %M.Book{title: "Domain Modeling Made Functional", author: "Scott Wlaschin"}
                 ]
               }}
     left:  {
              :ok,
              %Bookshop.Model.Order{
                address: %Bookshop.Model.Address{city: nil, other: "Freedom str 7/42 City State", state: nil},
                books: [
RED                  %Bookshop.Model.Book{title: "Domain Modeling Made Functional", author: "Scott Wlaschin"},
RED                  %Bookshop.Model.Book{title: "Distributed systems for fun and profit", author: "Mikito Takada"},
                  %Bookshop.Model.Book{author: "Marx, Valim, Tate", title: "Adopting Elixir"}
                ],
                client: %Bookshop.Model.User{id: "Joe", name: "Joe"}
              }
            }
     right: {
              :ok,
              %Bookshop.Model.Order{
                address: %Bookshop.Model.Address{city: nil, other: "Freedom str 7/42 City State", state: nil},
                books: [
                  %Bookshop.Model.Book{author: "Marx, Valim, Tate", title: "Adopting Elixir"},
GREEN             %Bookshop.Model.Book{title: "Distributed systems for fun and profit", author: "Mikito Takada"},
GREEN             %Bookshop.Model.Book{title: "Domain Modeling Made Functional", author: "Scott Wlaschin"}
                ],
                client: %Bookshop.Model.User{id: "Joe", name: "Joe"}
              }
            }
     stacktrace:
       test/solution_test.exs:11: (test)


Finished in 0.01 seconds (0.00s async, 0.01s sync)
5 tests, 1 failure, 4 excluded
```

опять проблема в порядке книг в books поле

порядок отличается потому, что
- в solution-2:
```elixir
    |> Enum.reduce({[], nil}, fn                         # <<<
      {:ok, book}, {books, nil} -> {[book | books], nil}
      {:error, error}, {books, nil} -> {books, {:error, error}}
      _maybe_book, acc -> acc
    end)
```

- solution-3:

```elixir
      books =
        Enum.map(books_data, fn one_book_data ->
          C.validate_book!(one_book_data )
        end)
```
в этом коде нет разворачивания(reverse order)
как вариант решения можно сортировать книги внутри создания Order:

```elixir
defmodule Bookshop.Model do
  # ...
  defmodule Order do
    defstruct [:client, :address, :books]

    def create(client, address, books) do
      %__MODULE__{
        client: client,
        address: address,
        books: Enum.sort(books)   # +
      }
    end
  end

end
```
теперь синхронизуем порядок книг в solution-1 solution-2 запуская для них тесты

и потом снова смотрим на тесты solution-3
```sh
mix test
Running ExUnit with seed: 603072, max_cases: 8

.....

  1) test invalid address (Bookshop.SolutionTest)
     test/solution_test.exs:45
     Assertion with == failed
     code:  assert S.handle(data) == {:error, :invalid_address}
     left:  {:error, "InvalidAddress wrong"}
     right: {:error, :invalid_address}
     stacktrace:
       test/solution_test.exs:50: (test)



  2) test invalid user (Bookshop.SolutionTest)
     test/solution_test.exs:37
     Assertion with == failed
     code:  assert S.handle(data) == {:error, :user_not_found}
     left:  {:error, "UserNotFound Nemean"}
     right: {:error, :user_not_found}
     stacktrace:
       test/solution_test.exs:42: (test)



  3) test invalid book (Bookshop.SolutionTest)
     test/solution_test.exs:53
     Assertion with == failed
     code:  assert S.handle(data) == {:error, :book_not_found}
     left:  {:error, "BookNotFound Functional Web Development with Elixir, OTP and Phoenix Lance Halvorsen"}
     right: {:error, :book_not_found}
     stacktrace:
       test/solution_test.exs:60: (test)

.

  4) test invalid incoming data (Bookshop.SolutionTest)
     test/solution_test.exs:31
     Assertion with == failed
     code:  assert S.handle(valid_data) == {:error, :invalid_incoming_data}
     left:  {:error, "InvalidIncomingData"}
     right: {:error, :invalid_incoming_data}
     stacktrace:
       test/solution_test.exs:34: (test)


Finished in 0.05 seconds (0.00s async, 0.05s sync)
10 tests, 4 failures
```
### допиливаем тесты на solution-3 чтобы при ошибках выдвало атомы

лучше чтобы клиентам отправлялись строковые представления об ошибках валидации
но для простоты, чтобы не исправлять solution-1 solution-2 сделаем так чтобы
solution3 при фейлах тоже выдавало атомы:

> добавляем Logger:
```elixir
defmodule Bookshop.Solution3 do
  alias Bookshop.Model, as: M
  alias Bookshop.Controller, as: C
  alias Bookshop.Errors, as: E

  require Logger # +

  @spec handle(map()) :: {:ok, M.Order.t()} | {:error, any()}
  def handle(data) do
    try do
      # без измнений
    rescue
      e in [E.InvalidIncomingData, E.UserNotFound, E.InvalidAddress, E.BookNotFound] ->
        Logger.error(Exception.message(e)) # выводим текст в консоль
        {:error, E.description(e)}
    end
  end

end
```

теперь сделаем функцию которая бы преобазовывала исключения в атомы
```elixir
defmodule Bookshop.Errors do
  defmodule InvalidIncomingData do ... end
  defmodule UserNotFound do ... end
  defmodule InvalidAddress do ... end
  defmodule BookNotFound do ... end

  # new:
  def description(%InvalidIncomingData{}), do: :invalid_incoming_data
  def description(%InvalidAddress{}), do: :invalid_address
  def description(%UserNotFound{}), do: :user_not_found
  def description(%BookNotFound{}), do: :book_not_found

end
```

```sh
mix test
```
```html
Compiling 1 file (.ex)
Generated bookshop app
Running ExUnit with seed: 912199, max_cases: 8

.....
13:34:11.976 [error] InvalidAddress wrong       # << вывод из Logger-а
.
13:34:11.979 [error] UserNotFound Nemean
.
13:34:11.979 [error] InvalidIncomingData
.
13:34:11.979 [error] BookNotFound Functional Web Development with Elixir, OTP and Phoenix Lance Halvorsen
..
Finished in 0.04 seconds (0.00s async, 0.04s sync)
10 tests, 0 failures
```

тесты работают, теепрь можно сравнить solution-3 и solution-2

solution3.ex:
```elixir
defmodule Bookshop.Solution3 do
  alias Bookshop.Model, as: M
  alias Bookshop.Controller, as: C
  alias Bookshop.Errors, as: E

  require Logger

  @spec handle(map()) :: {:ok, M.Order.t()} | {:error, any()}
  def handle(data) do
    try do
      data = C.validate_incoming_data!(data)

      %{
        "user" => username,
        "address" => address_str,
        "books" => books_data
      } = data

      cat = C.validate_user!(username)
      address = C.validate_address!(address_str)

      books =
        Enum.map(books_data, fn one_book_data ->
          C.validate_book!(one_book_data)
        end)

      order = M.Order.create(cat, address, books)
      {:ok, order}
    rescue
      e in [E.InvalidIncomingData, E.UserNotFound, E.InvalidAddress, E.BookNotFound] ->
        Logger.error(Exception.message(e))
        {:error, E.description(e)}
    end
  end
end
```

приемущества solution-3:
- четкий, компактный и понятный код,
- код легко чистается и воспринимается линейно
- сразу виден happy path
- обработка ошибок тоже видна и находится отдельно, занимая мало места
- намного короче и понятнее чем solution-2
- очень просто поменять местами обработчки(ф-и валидации) и добавить новые.

что не так с solution-3:
- норм для сторонников делать логику программы на исключениях

### почему не любят исключения
- ожидаешь в try-rescue только свои исключения а по факту в него прилетают
  исключения из других каки-то модулей, из сторонних библиотек
- часто бывает так что тяжело понять откуда вообще взялось исключение
  это особенно актуально для всяких там RuntimeError
  - именно поэтому и рекомендуется делать пользовательские исключения и
    отлавливать только их:
```elixir
    try do
      # ...
    rescue
      e in [E.InvalidIncomingData, E.UserNotFound, E.InvalidAddress, E.BookNotFound] ->
        # ...
    end
```

но есть способ писать красивый и понятный код и без исключений (solution-6)





## 09_05 Решение 4. Монада Result и оператор bind

начнём сразу с чистой практики без теоретической подготовки

В этом уроке будем улучшать solution-2.ex

вот часть кода 2го решения.
```elixir
  def handle_user(data, state) do
    case C.validate_user(data["user"]) do
      {:ok, user} ->                               # <
        state = Map.put(state, :user, user)        # <
        handle_address(data, state)

      {:error, error} ->                           # <
        {:error, error}                            # <
    end
  end

  def handle_address(data, state) do
    case C.validate_address(data["address"]) do
      {:ok, address} ->                             # <
        state = Map.put(state, :address, address)   # <
        create_order(data, state)

      {:error, error} ->                            # <
        {:error, error}                             # <
    end
  end
```
ранее уже обсуждали то, что здесь повторяется один и тот же паттерн
- case
- вызов функции
- при успехе идём дальше - вызов следующей ф-и в цепочке
- при ошибке - сразу вернуть ошибку, остановив цепочку вызовов

другими словами в том решении у нас есть цепочка функций, и на каждом шаге
идёт оценка того идём дальше или "падаем" с ошибкой

тут возникает идея как бы так связать функции на основе нужного нам паттерна.

по аналогии с оператором pipe(`|>`) - он по сути связывает функции передавая
output одной как input в первый аргумент следующей в цепочке ф-и
```elixir
  # f1 |> f2 |> f3 |> f4
```

но pipe никак не преобразует промежуточные резульаты, а просто прокидывает их
дальше.

нам же нужен своего рода "оператор" который бы реализовывал наш паттерн:
```elixir
  def handle_address(data, state) do
    case C.validate_X(data["KEY"]) do               # <
      {:ok, value} ->                               # <
        state = Map.put(state, :key, value)         # <
        next_chanined_func(data, state)             # <

      {:error, error} ->                            # <
        {:error, error}                             # <
    end
  end
```

```elixir
  # f1 >>= f2 >>= f3 >>= f4
```
и так чтобы он умел останавливать цепочку выполнений при ошибках


в FP Haskell есть такой оператор - и называется `bind` ( обозначается `>>=`)
этот Bind оператор работает с ф-ями которые возращают результат в виде:
- {:ok, result} | {:error, error}  - эту вещь еще называют "monada result"

monada result - это значение спец. типа, содержащие кроме самого значения
результата контекст в котором храниться успешность выполнения
то есть здесь это можно обозначить внутри кортежа {:ok, _} и {:erorr, _}
атомами :ok и :error

в Elixir нет оператора `bind` (>>=), но можно саму написать функцию, заменяющую
этот оператор.

lib/fp.ex
```elixir
defmodule FP do

  def bind(f1, f2, args) do
    case f1.(args) do
      {:ok, result} -> f2.(result)
      {:error, error} -> {:error, error}
    end
  end
end
```

готово, но пользоваться этим будет не удобно.
потому как объединить в чепочку более 2х функций будет трудно.

сделаем так чтобы результат bind можно было объединять в чепочку.

сделаем так чтобы bind возращал не результат вычисления(monada result), а
своего рода "ленивое вычислени" - другую функцию. То есть сделаем так чтобы
наш bind Не делал само вычисление а строил композицию двух функций, возращая
функцию внутри которой описано ленивое вычисление которое можно будет вызвать
по требованию:

```elixir
  def bind(f1, f2) do
    fn args ->
      case f1.(args) do
        {:ok, result} -> f2.(result)
        {:error, error} -> {:error, error}
      end
    end
  end
```

```elixir
bind(f1,f2)  # -  даст не результат, а функцию а значит:
bind(f1, f2) |> bind(f3) |> bind(f4)  # ... с любым кол-вом доп функций
```

```elixir
composited_func = bind(f1, f2) |> bind(f3) |> bind(f4) # строим чепочку
composited_func(args)                          # триггерим "ленивое вычисление"
```

> испытываем наш bind на простейшем практическом примере

```elixir
defmodule FP do

  def bind(f1, f2) do
    fn args ->
      case f1.(args) do
        {:ok, result} -> f2.(result)
        {:error, error} -> {:error, error}
      end
    end
  end

  # для удобства вызова
  # здесь идёт композиция двух функций и их вызов
  def try_bind do
    func = bind(&f1/1, &f2/1)
    func.(7)
  end

  def f1(a) do
    {:ok, a + 1}
  end

  def f2(a) do
    {:ok, a + 10}
  end

  def f3(a) do
    {:ok, a + 100}
  end

end
```

```sh
iex -S mix
```

```elixir
iex> FP.try_bind
{:ok, 18}
```

как это отработало
- вызвали f1(7) - дало 8  (сделало +1)
- вызвали f2(8) - дало 18 (сделало +10)


делаем композицию из 3х функций
```elixir
  def try_bind do
    func = bind(&f1/1, &f2/1) |> bind(&f3/1)
    #                         ^^^^^^^^^^^^^
    func.(7)
  end
  # ...
  def f3(a), do: {:ok, a + 100}
```

```elixir
iex>r FP
iex> FP.try_bind
{:ok, 118}
```

композиция из 4х функций:
```elixir
  def try_bind do
    func = bind(&f1/1, &f2/1) |> bind(&f3/1) |> bind(&f4/1)
    func.(7)
  end

  def f1(a), do: {:ok, a + 1}
  def f2(a), do: {:ok, a + 10}
  def f3(a), do: {:ok, a + 100}

  def f4(a), do: {:ok, a + 1000} # +
```

проверяем остановку посередине цепочки вызовов:

```elixir
  def f2(a) do
    # {:ok, a + 10}
    {:error, :boom} # это приведёт к остановке вызовов
  end
```

```elixir
r FP
{:reloaded, [FP]}

iex> FP.try_bind
{:error, :boom}
```

на Haskell этот же код создания композицией ф-и выглядил бы так

```elixir
  def try_bind do
    func = bind(&f1/1, &f2/1) |> bind(&f3/1) |> bind(&f4/1)
    func.(7)
    # Haskell:
    # 7 |> f1 >>= f2 >>= f3 >>= f4 >>=
  end
```


### пишем solution-4 используя свою функцию bind.

первая засада
в нашем bind по цепочке проходит одно значение,
то есть каждая последующая ф-я в цепочке принимает значение из предыдущей ф-и:

```elixir
# f1(a)
#     `-- распаковывается из кортежа(контекста) и подаётся в f2(a)
```

но нам нужно выстроить цепочку функций валидации.
а у нас валидирующие функции принимают два значения: data + state:

```elixir
  def handle_address(data, state) do
    #                ^^^^^^^^^^^
    case C.validate_address(data["address"]) do
      #                     ^^^^^^^^^^^^^^^
      {:ok, address} ->
        state = Map.put(state, :address, address)
        create_order(data, state)

      {:error, error} ->
        {:error, error}
    end
  end
```

вот и получается что напрямую через bind соединить
- validate_incomming_data
- validate_user
- validate_address
- validate_books
не получится, т.к. каждая такая ф-я при успехе возращает конкретную сущность
а не некий общий для всех state который бы мог ходить по всем ф-ям в цепочке
поэтому нужны функции обёртки, через которые мы могли бы передавать state:

по простому говоря нужны ф-и обёртки прогоняющие через себя значение state
и принимать и отдавать state:

- для validate_incoming_data ф-ю-обёртку пока не делаем:
  она у нас будет всё так же принимать на вход data и отдавать {:ok, data}
  при успехе и {:error, error} при ошибке

```elixir
  def step_validate_user(data) do
    case C.validate_user(data["user"]) do
      {:ok, user} ->
        state = %{data: data, user: user}
        {:ok, state}

      error -> error # {:error, error}
    end
  end

  def step_validate_address(state) do
    case C.validate_address(state.data["address"]) do
      {:ok, address} ->
        state = Map.put(state, :address, address)
        {:ok, state}

      error -> error
    end
  end

  # handle_books + create_order
  def step_validate_books(state) do
    state.data["books"]
    |> Enum.map(&C.validate_book/1)
    |> Enum.reduce({[], nil}, fn
      {:ok, book}, {books, nil} -> {[book | books], nil}
      {:error, error}, {books, nil} -> {books, {:error, error}}
      _maybe_book, acc -> acc
    end)
    |> case do
      {books, nil} ->
        state = Map.put(state, :books, books)
        {:ok, state}

      error -> error
    end
  end

  def step_create_order(state) do
    {:ok, M.Order.create(state.user, state.address, state.books)}
  end

```
формируем композицию функций (цепочку вызовов) на основе нашего bind
```elixir
  @spec handle(map()) :: {:ok, M.Order.t()} | {:error, any()}
  def handle(data) do
    f =
      FP.bind(&C.validate_incoming_data/1, &step_validate_user/1)
      |> FP.bind(&step_validate_address/1)
      |> FP.bind(&step_validate_books/1)
      |> FP.bind(&step_create_order/1)

    f.(data)
  end
```

проверка
```sh
mix compile
iex -S mix
```

```elixir
# берём тестовы данные
iex> data = Bookshop.test_data()
%{
  "address" => "Freedom str 7/42 City State",
  "books" => [
    %{
      "author" => "Scott Wlaschin",
      "title" => "Domain Modeling Made Functional"
    },
    %{
      "author" => "Mikito Takada",
      "title" => "Distributed systems for fun and profit"
    },
    %{"author" => "Marx, Valim, Tate", "title" => "Adopting Elixir"}
  ],
  "user" => "Joe"
}

# передаём данные в новое решение
iex> Bookshop.Solution4.handle(data)
{:ok,
 %Bookshop.Model.Order{
   client: %Bookshop.Model.User{id: "Joe", name: "Joe"},
   address: %Bookshop.Model.Address{
     state: nil,
     city: nil,
     other: "Freedom str 7/42 City State"
   },
   books: [
     %Bookshop.Model.Book{title: "Adopting Elixir", author: "Marx, Valim, Tate"},
     %Bookshop.Model.Book{
       title: "Distributed systems for fun and profit",
       author: "Mikito Takada"
     },
     %Bookshop.Model.Book{
       title: "Domain Modeling Made Functional",
       author: "Scott Wlaschin"
     }
   ]
 }}
```

запускаем тесты исправляя их так чтобы работали через Solution4:
```elixir
defmodule Bookshop.SolutionTest do
  use ExUnit.Case
  alias Bookshop.Model, as: M
  # alias Bookshop.Solution1, as: S
  # alias Bookshop.Solution2, as: S
  # alias Bookshop.Solution3, as: S
  alias Bookshop.Solution4, as: S   # <<<
  # .. код тестов без изменений
```


Для большей правильности дописываю обёртку для validate_incoming_data
чтобы эта ф-я принимала data а выдвала state, который бы уже дальше передавался
по всем другим validation-функциям. Так чтобы можно было например вместо ф-и
step_validate_user поставить любую другую:

```elixir
  def handle(data) do
    f =
      FP.bind(&step_validate_incoming_data/1, &step_validate_user/1)
      |> FP.bind(&step_validate_address/1)
      |> FP.bind(&step_validate_books/1)
      |> FP.bind(&step_create_order/1)

    f.(data)
  end

  def step_validate_incoming_data(data) do
    case C.validate_incoming_data(data) do
      {:ok, data} ->
        state = %{data: data}
        {:ok, state}

      error ->
        error
    end
  end

  def step_validate_user(state) do # << принимаю state а не data
    case C.validate_user(state.data["user"]) do
      {:ok, user} ->
        state = Map.put(state, :user, user)  # <<<
        {:ok, state}

      error ->
        error
    end
  end
```

сравнимаем решение-2 и решение-4

- по количеству кода примерно одинаково, но решение-4 более читабельное
потому как у нас перед глазами есть вся цепочка вызовов:
```elixir
  def handle(data) do
    f =
      FP.bind(&step_validate_incoming_data/1, &step_validate_user/1)
      |> FP.bind(&step_validate_address/1)
      |> FP.bind(&step_validate_books/1)
      |> FP.bind(&step_create_order/1)

    f.(data)
  end
```
тогда как в solution-2 вся цепочка "спрятана в матрёшку"

но доп. кода пришлось писать примерно столько же как в решении-2
просто bind не очень подходит конкретно к этому сценарию:
- когда у нас есть промежуточные результаты вычислений, которые нам надо
  прокидывать дальше по цеполчке до выхода

- bind очень хорошо подходит, когда вход одной функции совпадает с другой ф-ей
  (как в операторе pipe)

конкретно в нашем случае с валидацией, каждая валидирующая фун-я выдаёт свои
какие-то значения, то есть эти значения не совместимы между фун-ями цепочки
и пришлось писать обёртки над функциями чтобы запоминать их все в промежуточном
значении state.


#### копаем теорию ФП глубже: формализация FP.bind

```elixir
defmodule FP do

  @type successful() :: any()
  @type error() :: any()
  @type monada_result() :: {:ok, successful() | {:error, error()}}
  # придумываем тип функции для bind (для аргумента f1 и для f2)
  @type m_fun() :: (any() -> monada_result()) # описание типа для функции

  @spec bind(m_fun(), m_fun()) :: m_fun()
  def bind(f1, f2) do
    fn args ->
      case f1.(args) do
        {:ok, result} -> f2.(result)
        {:error, error} -> {:error, error}
      end
    end
  end
```

Вот эту штуку называю "монадой"(Monada)
```elixir
{:ok, successful() | {:error, error()}}
```
вообще монады бывают разные и эта одна из монад, причем достаточно популярная.
говорят что ф-я, которая возращает значение типа
`{:ok, successful() | {:error, error()}}`
(здесь мы его обозначем как  `@type monada_result()`)
является монодической функцией - здесь мы назовём её `m_fun` - @type m_fun()

вот и получается что в нашей системе типов монодическая функция (m_fun) это
- функция принимающая на вход один аргумент любого типа (`any()`)
- и возращающая monada_result. (т.е. обёртку в виде кортежа ok или error)
```elixir
  @type m_fun() :: (any() -> monada_result()) # Это описание типа для функции
```

вот и получается что наш bind это ф-я которая принимает две монодические
функии, и возращает как своё значение тоже монодическую функцию
```elixir
  @spec bind(m_fun(), m_fun()) :: m_fun()
  #          arg1     arg2        return
  def bind(f1, f2) do
    ...
  end
```
проверим корректность описания наших типов
```sh
mix compile
Compiling 2 files (.ex)
Generated bookshop app
# норм - ошибок нет
```

#### выход на sequence из Haskell

если посмотреть на этот код:
```elixir
  def step_validate_books(state) do
    state.data["books"]
    |> Enum.map(&C.validate_book/1)     # (1) отдаёт список monada_result()
    |> Enum.reduce({[], nil}, fn        # (2) свёртка списка из monada_result()
      {:ok, book}, {books, nil} ->
        {[book | books], nil}

      {:error, error}, {books, nil} ->
        {books, {:error, error}}

      _maybe_book, acc -> acc
    end)
    |> case do
      {books, nil} ->
        state = Map.put(state, :books, books)
        {:ok, state}

      {_, error} ->
        error
    end
  end
```
здесь у нас есть функция C.validate_book, которая
- на вход принимает "книги" (некий обьект)
- и возращает `monada_result()` (нами описанный выше тип обозначающий обёртку
  `{:ok,...}|{:error,...}`)

- Enum.map на выходе отдаст нам список из monada_result() для каждой из поданых
книг
- Enum.reduce (свёртка) нам нужна для того, чтобы пройтись по списку состоящему
  из monada_result() и вывести из него есть ошибки или нет

то есть другими словами весь этот код внутри step_validate_user по сути
generic поведение, которое можно было бы обобщить и абстрагировать

продумываем как это сделать
somefunc - имя нашей новой функции(пока не придумали как назвать)

```elixir
@spec somefunc([monada_result()]) :: {:ok, [successful()]} | {:error, error()}
#               (1)                  ^(2)      ^(3)                    ^(4)
```
то есть по сути такая функция somefunc перобразует список из monada_result() (1)
в новую монаду где либо список успешных значений либо ошибка

в Haskell есть такая библиотечная ф-я и называется `sequence`:
```elixir
@spec sequence([monada_result()]) :: {:ok, [successful()]} | {:error, error()}
```


```elixir
defmodule FP do

  @type successful() :: any()
  @type error() :: any()
  @type monada_result() :: {:ok, successful() | {:error, error()}}
  @type m_fun() :: (any() -> monada_result())

  #... bind

  # пишем свою реализацию sequence из Haskell (абстракция для вывода списка монад)
  @spec sequence([monada_result()]) :: {:ok, [successful()]} | {:error, error()}
  def sequence(result_list)
    result_list
    |> Enum.reduce({[], nil}, fn
      {:ok, result}, {results, nil} -> {[result | results], nil}
      {:error, error}, {books, nil} -> {results, {:error, error}}
      #                        ^flag of no-error
      _maybe_result, acc -> acc
    end)
    |> case do
      {results, nil} ->
        {:ok, results}

      {_, error} ->
        error
    end
  end
```

Теперь можно переписать вот этот код на использование абтсракции sequence
```elixir
  def step_validate_books(state) do
    state.data["books"]
    |> Enum.map(&C.validate_book/1)
    |> Enum.reduce({[], nil}, fn
      {:ok, book}, {books, nil} -> {[book | books], nil}
      {:error, error}, {books, nil} -> {books, {:error, error}}
      #                        ^flag of no-error
      _maybe_book, acc -> acc
    end)
    |> case do
      {books, nil} ->
        state = Map.put(state, :books, books)
        {:ok, state}

      {_, error} ->
        error
    end
  end
```

```elixir
  def step_validate_books(state) do
    state.data["books"]
    |> Enum.map(&C.validate_book/1)
    |> FP.sequence()
    |> case do
      {:ok, books} ->
        state = Map.put(state, :books, books)
        {:ok, state}

      error -> error # {:error, error} -> {:error, error}
    end
  end
```
проверяем запуская тесты - работает!

В кратце что мы здесь из новых фишек ФП освоили:
- посмотрели на монаду
- на связывание двух монодических функций в "одну" (композицию функций)
- преобразование списка монад(monada_result()) в новую монаду (sequence из Haskell)
  (эта ФП-шная фишка уже "чутка покруче"




## 09_06 Решение 5. Pipeline

начнём с обуждения недостатков solution-4

```elixir
  def handle(data) do
    f =
      FP.bind(&step_validate_incoming_data/1, &step_validate_user/1)
      |> FP.bind(&step_validate_address/1)
      |> FP.bind(&step_validate_books/1)
      |> FP.bind(&step_create_order/1)

    f.(data) # Запуск композиции всех функций
  end
```
Здесь:
- ф-я FP.bind связывает две функции, давая на выходе новую функцию, которая
  является композицей двух свазываемых ф-й. и эту новую функцию можно запустить
- через bind мы строить цепочку из функций, получая композицию из всех ф-йй
- f.(data) - запускаем саму обработку состоящую из композиции функций.

для воплощения этого подхода потребовалось:
- написать ф-и обёртки которые единообразно принимают state,
  и возращают либо изменённый state обёрнутый в кортеж либо с :ok
  либо с :error останавливая выполнение цепочки ф-й:

```elixir
  def step_validate_user(state) do
    case C.validate_user(state.data["user"]) do
      {:ok, user} ->
        state = Map.put(state, :user, user)
        {:ok, state}

      error ->
        error
    end
  end
```

В эликсир нет оператора bind как например а Haskell поэтому такое решение на
функцииях binx выглядит не таким изящным как могло бы быть:
```elixir
  def handle(data) do
    data
    |> step_validate_incoming_data
    >>= step_validate_user
    >>= step_validate_address
    >>= step_validate_books
    >>= step_create_order
  end
```

поэтому чаще используется такая вещь как pipeline

идея pipeline - передать сразу список функций для связывыния, вместо того
чтобы связывать их вот так вот попарно как в bind. А уже затем прогоним список
переданных ф-ий через Enum.reduce, поочередно вызывая каждую из них.

```elixir
defmodule FP do

  def pipeline(state, fun_list) do
    Enum.reduce(fun_list, {:ok, state}, fn f, acc -> ... end)
  end

end
```

- state - начальное состоние которое будем передавать во все ф-и из fun_list
- fun_list - список функций, которые нужно вызвать

```elixir
  def pipeline(state, fun_list) do
    Enum.reduce(fun_list, {:ok, state}, fn
      f, {:ok, curr_state} -> f.(curr_state)  # 1 clause
      f, {:error, error} -> {:error, error}   # 2 clause
    end)
  end
```

пишем спеку (типы для ф-и)
```elixir
defmodule FP do
  @spec pipeline( any(), [(any() -> {:ok, any()} | {:error, any()})]) ::  ...
  #                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  #                     ^                      \ /
  #               1     3                       2
  def pipeline(state, fun_list) do
    Enum.reduce(fun_list, {:ok, state}, fn
      f, {:ok, curr_state} -> f.(curr_state)
      f, {:error, error} -> {:error, error}
    end)
  end
end
```

- 1. any() - входное значение (1й аргумент)
- 2. тип одной функции передаваемая в список ф-ий для pipeline
     (монодическая ф-я которая возращает либо :ok+state либо :error
- 3. список таких монодический функций для выстраивания pipeline


упростим спецификацию вынеся типы в @type
```elixir
defmodule FP do
  @type successful() :: any()
  @type error() :: any()
  @type monada_result() :: {:ok, successful() | {:error, error()}}
  @type m_fun() :: (any() -> monada_result())

  @spec pipeline(any(), [m_fun()]) :: monada_result()
  def pipeline(state, fun_list) do
    Enum.reduce(fun_list, {:ok, state}, fn
      f, {:ok, curr_state} -> f.(curr_state)
      _f, {:error, error} -> {:error, error}
    end)
  end
end
```

реализация solution-5 на pipeline

```elixir
defmodule Bookshop.Solution5 do
  alias Bookshop.Model, as: M
  alias Bookshop.Solution4, as: S4

  @spec handle(map()) :: {:ok, M.Order.t()} | {:error, any()}
  def handle(data) do
    FP.pipeline(data, [
      &S4.step_validate_incoming_data/1,
      &S4.step_validate_user/1,
      &S4.step_validate_address/1,
      &S4.step_validate_books/1,
      &S4.step_create_order/1
    ])
  end
end
```

- здесь не стали дублировать код тех же самых функций что уже нами описаны в
  solution4 а импортировали их прямо от туда.

по аналогии переводит solution_test.ex уже на 5-е решение и проверяем на
валидность - все тесты проходят


такой подход достаточно популярен в Эликисир, потому что такой же подход
исп-ся например в либе `Plug` - эта либа часть веб-фреймворка `Phoenix`
Plug - обрабатывает входящие http-запросы, прогоняя их через цепочки функций
но обычно там используются не ф-ии, а макросы.
когда пишут используя Phoenix можно определить шаги, через которые должна
проходить обработка http запроса (авторизация, десериализация Json и т.д)
до того как быть отданной в контроллер.

и принцип работы в биб-ке Plug точно такой же как в только что нами реализованной
функции pipeline

- задаются "шаги" функции(действия) которые будут выполняться в цепочке действий
- если ок то цепочка передаётся к след. шагу
- если ошибка - то цепочка вызовов прерывается и Plug отправляет например код
  ошибки.
- через цепочку проходит некий state.
  в биб-ке State он формализован структурой данных Plug.Conn
  в этой структуре содержиться всё что есть в Http-запросе:
  uri, query, params, body_params, headers и прочее
  так же есть всё что нужно для http-ответа: status, body, headers и проч.


### улучшаем тесты.
делаем так чтобы для всех solution-* прогонялись один и тот же набор тестов

test/support/my_assertions.ex
```elixir
defmodule MyAssertions do
  use ExUnit.Case # чтобы был доступен макрос assert

  def assert_many(modules, fun, args, expected_result) do
  #                1        2     3        4
    Enum.each(modules, fn module ->
      got_result = Kernel.apply(module, fun, args)
      assert got_result == expected_result
    end)
  end
end
```

- 1 список модулей из которых нужно зывать одно и ту же фун-ию
- 2 имя функции (атом) для вызова
- 3 список аргументов для передачи в вызываемую ф-ю
- 4 ожидаемый результат

Это способ динамически вызвать функцию по имени её модуля и по имени самой
функции в этом модуле, передавая ей заданный список аргументов
```elixir
      got_result = Kernel.apply(module, fun, args)
```

```elixir
defmodule Bookshop.SolutionTest do
  use ExUnit.Case
  alias Bookshop.Model, as: M

  @test_solutions [         # список модулей для вызова
    Bookshop.Solution1,
    Bookshop.Solution2,
    Bookshop.Solution3,
    Bookshop.Solution4,
    Bookshop.Solution5,
  ]
  alias Bookshop.Solution5, as: S # пока так чтобы остальные тесты не падали

  test "create order" do
    # .. пока без измнений
  end

  test "invalid incoming data" do
    valid_data = TestData.invalid_data()

    # assert S.handle(valid_data) == {:error, :invalid_incoming_data}

    MyAssertions.assert_many(   # < добавляем свою функцию
      @test_solutions,          # здесь все наши модули
      :handle,                  # это имя вызываемой функции  S.handle(..)
      [valid_data],             # аргументы в фнукцию всегда в списке
      {:error, :invalid_incoming_data} # Ожидаемый результат
    )
  end

  # остальные тесты без изменений
end
```

запускаем проверям - работает
```sh
 mix test
Running ExUnit with seed: 810175, max_cases: 8

.....
20:18:42.896 [error] InvalidIncomingData
.
20:18:42.902 [error] UserNotFound Nemean
..
20:18:42.903 [error] InvalidAddress wrong
.
20:18:42.906 [error] BookNotFound Functional Web Development with Elixir, OTP and Phoenix Lance Halvorsen
.
Finished in 0.05 seconds (0.00s async, 0.05s sync)
10 tests, 0 failures
```


