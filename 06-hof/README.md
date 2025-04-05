# Урок 6 Функции высшего порядка.

- 1 Map Filer
- 2 Reduce (Fold)
- 3 Модуль Enum
- 4 Конструкторы списков
- 5 Модуль Stream


Во всех функциональных языках программирования - функции можно передавать как
обычные значения. То есть функцию можно присвоить в переменную, передать
аргументов в другую функцию(метод) и вернуть как значение из функции.

Функции высшего порядка(HOF) hight order functions - это такие функции которые
либо принимают, либо возвращаю другие функции.
В эликсире есть стандартный модуль `Enum` с такими HOF функциями.
И самые главные из них это Map, Filter, Reduce

> Note:
(в других ЯП ф-ю Redure еще называют Fold (свёртка))


## Map, Filter

В стандартной Elixir-библиотеке порядок аргументов у HOF-функций такой, чтобы
их было удобно использовать c оператором `pipe` (`|>`)
Поэтому первым аргументом принимается коллекция.

пример псевдокода, где используется оператор pipe:
```elixir
defmodule HOF do
  collection
  |> Enum.map(fn1)
  |> Enum.filter(fn2)
  |> Enum.reduce(acc, fn3)
end
```

Пример того же самого кода в Erlang:
(Обрати внимание порядок аргументов другой и в Erlang нет оператора pipe)

```erlang
List1 = []
List2 = lists:map(Fn1, List1)
List3 = lists:filter(Fn2, List2)
List4 = lists:foldl(Fn3, Acc, List3)
```

как видем в Erlang коллекция передаётся последним аргументом
(здесь это List1, List2, List3)
`list` - это название Erlang-модуля

foldl - это левая(l) свёртка (в эликсир для этого аналог Reduce)

В общем как видим в Erlang принято передавать коллекцию последним аргументом
а так как переменные в Erlang иммутабельные и нет оператора pipe
приходится для каждого изменения создавать новую переменную, здесь это
List1, List2, List3, List4...


Как видно в Elixir код более краткий и ёмкий, просто за счёт особенностей
работы pipe оператора.


## Enum.map
Начинаем практику работы с Enum.map

Enum.map
- 1й параметр - коллекция
- 2й параметр - некая функция для обхода каждого элемента мапы

```sh
touch hof.exs
```

> hof.exs
```elixir
defmodule HOF do

end
```

```sh
iex hof.exs

Erlang/OTP 26 [erts-14.2.4] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [jit:ns]

Interactive Elixir (1.16.2) - press Ctrl+C to exit (type h() ENTER for help)
```

Простейший пример
- создаём коллекцию чисел
- затем создаём функцию присваивая её в переменную `f`
- и получаем новую коллекцию скармливая `Enum.map` и данные и функцию
- результатом работы `Enum.map` будет новый изменённый список, где к каждому эл-ту
  была применена заданная функция `f`

```elixir
iex(1)> list = [1, 2, 3, 4, 5]
[1, 2, 3, 4, 5]
iex(2)> f = fn i -> i * i end
#Function<42.105768164/1 in :erl_eval.expr/6>
iex(3)> Enum.map(list, f)
[1, 4, 9, 16, 25]
```

По сути функция Enum.map - это просто готовая и удобная обёртка которую можно
реализовать и самому, используя рекурсивные функции с аккумуляторами.
Естественно всё это делать не надо, потому как это уже реализовано самими
разработчиками Elixir.


Пример кода который делали через рекурсию с аккумулятором.
(для закрепления и понимания повторим через Enum.map тоже что делали через
рекурсию с аккумулятором)

Задаём через модуль данные для обработки
```elixir
defmodule HOF do

  def test_data() do
    # {tag, id, name, age}
    [
      {:user, 1, "Bob", 15},
      {:user, 2, "Bill", 25},
      {:user, 3, "Helen", 10},
      {:user, 4, "Kate", 11},
      {:user, 5, "Yura", 31},
      {:user, 6, "Dima", 65},
      {:user, 7, "Yana", 35},
      {:user, 8, "Diana", 41},
    ]
  end
end
```

Теперь можно прямо в консоли создать функцию которая позволит из этих данных
получить список в виде id-name
```exs
iex(6)> r HOF
{:reloaded, [HOF]}

# доступ к тестовым данным содержащих пользователей
iex(7)> users = HOF.test_data
[
  {:user, 1, "Bob", 15},
  {:user, 2, "Bill", 25},
  {:user, 3, "Helen", 10},
  {:user, 4, "Kate", 11},
  {:user, 5, "Yura", 31},
  {:user, 6, "Dima", 65},
  {:user, 7, "Yana", 35},
  {:user, 8, "Diana", 41}
]

iex(8)> f = fn {:user, id, name, _} -> {id, name} end
#Function<...>

iex(9)> Enum.map(users, f)
[
  {1, "Bob"},
  {2, "Bill"},
  {3, "Helen"},
  {4, "Kate"},
  {5, "Yura"},
  {6, "Dima"},
  {7, "Yana"},
  {8, "Diana"}
]
```

## UpperCase именён пользователей

```exs
iex(10)> f = fn {:user, id, name, age} ->
...(10)> {:user, id, String.upcase(name), age}
...(10)> end
#Function<42.105768164/1 in :erl_eval.expr/6>


iex(11)> Enum.map(users, f)
[
  {:user, 1, "BOB", 15},
  {:user, 2, "BILL", 25},
  {:user, 3, "HELEN", 10},
  {:user, 4, "KATE", 11},
  {:user, 5, "YURA", 31},
  {:user, 6, "DIMA", 65},
  {:user, 7, "YANA", 35},
  {:user, 8, "DIANA", 41}
]
```


## Enum.filter
Как и `Enum.map` тоже принимает два аргумента.

- первый аргумент коллекция
- вторым аргументом предикат - т.е. функция принимающая элемент коллекции и
  возвращающая логическое значение (true|false)
- filter оставляет все элементы на которые функция-предикат отдаёт true
  то есть на true filter пропускает элементы в окончальный результат,
  а на false Элемент из изначальной коллекции отбрасывается и не попадает
  в коллекцию окончального результата

Простейший пример использования Enum.filter с заданием предиката "на лету"
```exs
iex(1)> list = [1, 2, 3, 4, 5]
[1, 2, 3, 4, 5]
iex(12)> Enum.filter(list, fn i -> i >= 3 end)
[3, 4, 5]
```

Взять из коллекции пользователей только тех кто старше 16

```exs
iex(13)> is_adult = fn {:user, _, _, age} -> age >= 16 end
#Function<42.105768164/1 in :erl_eval.expr/6>

iex(14)> Enum.filter(users, is_adult)
[
  {:user, 2, "Bill", 25},
  {:user, 5, "Yura", 31},
  {:user, 6, "Dima", 65},
  {:user, 7, "Yana", 35},
  {:user, 8, "Diana", 41}
]


iex(15)> Enum.filter(users, fn {:user, _, _, age} -> age < 16 end)
[{:user, 1, "Bob", 15}, {:user, 3, "Helen", 10}, {:user, 4, "Kate", 11}]
```

- недостаток в вышеописанных функция предикатах то что возраст фильтрации в них
"захардкожен"



### реализация функции Split-by-age

Принимает коллекцию и значение возраста для разделения, и возвращает два списка

```elixir
defmodule HOF do

  def test_data() do
    # {tag, id, name, age}
    [
      {:user, 1, "Bob", 15},
      {:user, 2, "Bill", 25},
      {:user, 3, "Helen", 10},
      {:user, 4, "Kate", 11},
      {:user, 5, "Yura", 31},
      {:user, 6, "Dima", 65},
      {:user, 7, "Yana", 35},
      {:user, 8, "Diana", 41},
    ]
  end

  def split_by_age(users, age_limit) do
    predicate1 = fn {:user, _, _, age} -> age < age_limit end
    predicate2 = fn user -> not pred1.(user) end
    # pred2 = fn {:user, _, _, age} -> age >= age_limit end

    users1 = Enum.filter(users, predicate1)
    users2 = Enum.filter(users, predicate2)
    {users1, users2}
  end
end
```

проверяем работу

```exs
iex(16)> r HOF

{:reloaded, [HOF]}
iex(17)> HOF.split_by_age(users, 16)
{[
   {:user, 1, "Bob", 15},
   {:user, 3, "Helen", 10},
   {:user, 4, "Kate", 11}
],
 [
   {:user, 2, "Bill", 25},
   {:user, 5, "Yura", 31},
   {:user, 6, "Dima", 65},
   {:user, 7, "Yana", 35},
   {:user, 8, "Diana", 41}
 ]}

iex(18)> HOF.split_by_age(users, 26)
{[
   {:user, 1, "Bob", 15},
   {:user, 2, "Bill", 25},
   {:user, 3, "Helen", 10},
   {:user, 4, "Kate", 11}
 ],
 [
   {:user, 5, "Yura", 31},
   {:user, 6, "Dima", 65},
   {:user, 7, "Yana", 35},
   {:user, 8, "Diana", 41}
 ]}
```



