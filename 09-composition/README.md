# Урок 9 Композиция функций

- 09.01 Задача на композицию функций
- 09.02 Решение 1. Вложенные case
- 09.03 Решение 2. Каждый case в отдельной функции
- 09.04 Решение 3. Использование исключений
- 09.05 Решение 4. Монада Result и оператор bind
- 09.06 Решение 5. Pipeline
- 09.07 Решение 6. do-нотация
- 09.08 Что такое монада?


### 09.01 Задача на композицию функций

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
@spec validate_incomming_data(map()) :: {:ok, map()} | {:error, :invalid_incomming_data}
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
|> validate_incomming_data()
|> validate_user()
|> validate_address()
|> validate_book()     # list!
|> create_order()
```
просто все наши функции соединяем через оператор pipe

но увы у нас в системе и коде возможны ветвления
```elixir
{:ok, map()} | {:error, :invalid_incomming_data}
```
а оператор pipe это вообще не про ветвление

Весь этот урок мы и будем думать как реализовать соединение наших функций так
чтобы это было и красиво и понятно.




## 09.02 Решение 1. Вложенные case

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
@spec validate_incomming_data(map()) :: {:ok, map()} | {:error, :invalid_incomming_data}
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

  @spec validate_incomming_data(map()) :: {:ok, map()} | {:error, :invalid_incomming_data}
  def validate_incomming_data(data) do
    if rand_success() do
      {:ok, data}
    else
      {:error, :invalid_incomming_data}
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
iex(2)> B.Controller.validate_incomming_data(42)
{:ok, 42}
...
iex(17)> B.Controller.validate_incomming_data(42)
{:error, :invalid_incomming_data}

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
    case C.validate_incomming_data(data) do
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
    case C.validate_incomming_data(data) do
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
    case C.validate_incomming_data(data) do
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
{:error, :invalid_incomming_data}


iex> B.Solution1.handle(data)
{:error, :user_not_found}

iex> B.Solution1.handle(data)
{:error, :invalid_address}
```

> Валидация книг

```elixir
  def handle(data) do
    case C.validate_incomming_data(data) do
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
{:error, :invalid_incomming_data}
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


