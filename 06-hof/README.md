# Урок 6 Функции высшего порядка.

- 1 Map Filer
- 2 Reduce (Fold) (Свёртка)
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


## 06.01. Map, Filter

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


## 06.02. Reduce (Fold) (Свёртка)

В разных функциональных языках функцию "свёртки" называют по разному.
В Elixir её называют Reduce, в некоторых других(например в Erlang) - Fold.
Reduce можно перевести как сокращение, Fold - сворачивание, но суть та же.
Reduce - принимает коллекцию, а возвращает одно единственное значение, другими
словами эта функция как бы сварачивает коллекцию значений в некое одно значение.
Reduce помудрённее чем Enum.map и Enum.filter, но по сути надо просто разобраться
со всеми аргументами и как это вообще работает.


есть ф-я `Enum.reduce/3` принимающая 3 аргумента:
- коллекцию, аккумулятор, и "сворачивающую" функцию(reducer/2):
- сворачивающая функция принимает два аргумента: item & acc и возвращает новое
  значение acc(аккумулятора)
- Enum.reduce/3 возвращает итоговый acc прошедший через все значения и reducer

```elixir
 """
  Enum.reduce/3 -> final_acc
  arg:
   - collection
   - accumulator
   - reducer (folding function)

  reducer/2 -> new_acc
  arg:
   - item
   - acc
  """
```

```sh
iex
```
```elixir-iex
Erlang/OTP 26 [erts-14.2.1] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [jit:ns]
Interactive Elixir (1.18.3) - press Ctrl+C to exit (type h() ENTER for help)

# summ all elements
iex(1)> Enum.reduce([1, 2, 3], 0, fn item, acc -> item + acc end)
6

# multiply all elements
iex(4)> Enum.reduce([1,3,4,5], 1, fn item, acc -> item * acc end)
60
```

```elixir
# сложение всех элементов
Enum.reduce([1, 2, 3], 0, fn item, acc -> item + acc end)

# умножение всех эленетов
Enum.reduce([1, 3, 4, 5], 1, fn item, acc -> item * acc end)

# схема для обоих
# Enum.reduce(collection, reducer)
```


```elixir
# compile
iex(1)> c "hof.exs"
[HOF]

# run
iex(2)> users = HOF.test_data
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
```

черновик реализации подсчёта среднего возраста
> hof.ex
```elixir
defmodule HOF do

  def test_data() do
    # {tag, id, name, age}
    [
      {:user, 1, "Bob", 15},
      ...
    ]
  end

  def get_avg_age(users) do
    reducer =
      fn {:user, _, _, age}, {num_users, total_age} ->
        {num_users + 1, total_age + age}
      end

    Enum.reduce(users, {0, 0}, reducer)
  end
```


Обновляю модуль и запускаю новую функцию из него
```elixir
iex(4)> r HOF
    warning: redefining module HOF (current version defined in memory)
    │
  1 │ defmodule HOF do
    │ ~~~~~~~~~~~~~~~~
    │
    └─ hof.exs:1: HOF (module)
{:reloaded, [HOF]}

iex(5)> HOF.get_avg_age(users)
{8, 233}
```

8 - кол-во пользователей
233 - сумма всех возрастов, нам же нужен средний возраст

корректирую так чтобы выводило средний возраст

> hof.ex
```elixir
defmodule HOF do

  def test_data() do
    # {tag, id, name, age}
    [
      {:user, 1, "Bob", 15},
      ...
    ]
  end

  def get_avg_age(users) do
    reducer =
      fn {:user, _, _, age}, {num_users, total_age} ->
        {num_users + 1, total_age + age}
      end

    {total_users, total_age} =
      Enum.reduce(users, {0, 0}, reducer)

     total_age / total_users
  end
```

проверяю
```elixir
iex(6)> r HOF

iex(7)> HOF.get_avg_age(users)
29.125
```

как видно в Reducer ничего сложного нет, просто нужно разобраться с аргументами
В Enum.reducer так же как и для Enum.map Enum.filter принято функцию писать
как анонимную, то есть прямо на месте передаваемого аргумента:
```elixir
  def get_avg_age(users) do
    reducer = # безымянная функция присвоенная в переменную
      fn {:user, _, _, age}, {num_users, total_age} ->
        {num_users + 1, total_age + age}
      end

    {total_users, total_age} =
      Enum.reduce(users, {0, 0}, reducer)

     total_age / total_users
  end
```

Сокращается до (функция описывается прямо на месте передачи(как аргумент))
```elixir
  def get_avg_age(users) do
    {total_users, total_age} =
      Enum.reduce(users, {0, 0}, fn {:user, _, _, age}, {num_users, total_age} ->
        {num_users + 1, total_age + age}
      end)

     total_age / total_users
  end
```
По началу читать такой код может быть трудно, из-за большого количества
аргументов и паттерн матчинга специфичного для Elixir. Здесь есть и аргументы
для самого Enum.reduce + аргументы для функции reducer, которую передаём прямо
в виде аргумента - аннонимной функции.
В настоящих проектах, большие и сложные reducer фунции всё таки выносят отдельно
и лучше выносить её не в анонимную а в именованную:

```elixir
  def get_avg_age(users) do
    {total_users, total_age} =
      Enum.reduce(users, {0, 0}, &avg_age_reducer/2)

     total_age / total_users
  end

  # именнованная функция
  def avg_age_reducer({:user, _, _, age}, {num_users, total_age}) do
    {num_users + 1, total_age + age}
  end
```

Совет для новичков:
- для упрощения понимания кода, можно reducer функции не задавать сразу как
  аргумент, а выносить отдельно либо как именнованую либо как безымянную(через
  локальную переменную)
- и уже по мере привыкания и закрепления понимания, можно будет писать такие
  много-аргументные функции прямо в месте их передачи(как все и делают)



## Пример 2 разделение пользователей на два списка по условию через Reduce

вот наша первая реализация через filter.
```elixir
  def split_by_age(users, age_limit) do
    pred1 = fn {:user, _, _, age} -> age < age_limit end
    pred2 = fn user -> not pred1.(user) end

    users1 = Enum.filter(users, pred1)
    users2 = Enum.filter(users, pred2)
    {users1, users2}
  end
```

Если присмотреться то станет понятно, что эта реализация не эффективная.
т.к. здесь идёт два прохода по списку users (Enum.filter вызывается дважды)
Эту же задачу можно решить за 1 проход через Enum.reduce

```elixir
  def split_by_age(users, age_limit) do
    Enum.reduce(
      users,    # collection
      {[], []}, # acc
      # reducer:
      fn {:user, _ , _, age} = user, { younger_list, older_list } ->
        if age < age_limit do
          {[user | younger_list], older_list}
        else
          {younger_list, [user | older_list]}
        end
      end
    )
  end
```

```elixir
 fn {:user, _ , _, age} = user, {younger_list, older_list} -> ... end
 #  ^^^^^item(arg1)^^^^^^^^^^^  ^^^^^^^^ acc(arg2 ^^^^^^^^
 #                      ^^^^^^
 #                      так как сам user нужен для добавления в result-коллекцию
```


Проверяю работу
```elixir
iex(11)> HOF.split_by_age(users, 16)
{[{:user, 4, "Kate", 11}, {:user, 3, "Helen", 10}, {:user, 1, "Bob", 15}],
 [
   {:user, 8, "Diana", 41},
   {:user, 7, "Yana", 35},
   {:user, 6, "Dima", 65},
   {:user, 5, "Yura", 31},
   {:user, 2, "Bill", 25}
 ]}
```


## 3й пример - Поиск самого старшего пользователя из коллекции

```elixir
  def get_oldest_user(users) do
    [first_user | rest_users] = users       # беру первого user как max

    Enum.reduce(                            # Enum.reduce/3
      rest_users,                           # collection
      first_user,                           # accumulator
      fn curr_user, acc ->                  # reducer
        {:user, _, _, curr_age} = curr_user
        {:user, _, _, max_age} = acc
        if curr_age > max_age do
          curr_user
        else
          acc
        end
    end)
  end
```


```elixir
iex()> r HOF

iex()> HOF.get_oldest_user(users)
{:user, 6, "Dima", 65}
```

Очень часто нужно брать первый item из коллекции, поэтому для этого специально
сделали функцию `Enum.reduce/2`. Он ведёт себя точно так же как в примере выше
при старте в аккумутятор кладётся первый элемент коллекции, поэтому сам acc
не нужно задавать:

updated:
```elixir
  def get_oldest_user(users) do
    Enum.reduce(                      # Enum.reduce/2
      users,                          # collection
      fn curr_user, acc ->            # reducer
        {:user, _, _, curr_age} = curr_user
        {:user, _, _, max_age} = acc
        if curr_age > max_age do
          curr_user
        else
          acc
        end
    end)
  end
```


Смотрим документацию по Enum.reduce/3 и Enum.reduce/2 прямо из iex
(Удобно когда нужно что-то вспомнить или посмотреть примеры)
```elixir
iex()> h Enum.reduce/3
```
output:
```c
/*
                        def reduce(enumerable, acc, fun)

  @spec reduce(t(), acc(), (element(), acc() -> acc())) :: acc()

Invokes fun for each element in the enumerable with the accumulator.

The initial value of the accumulator is acc. The function is invoked for each
element in the enumerable with the accumulator. The result returned by the
function is used as the accumulator for the next iteration. The function
returns the last accumulator.

## Examples

    iex> Enum.reduce([1, 2, 3], 0, fn x, acc -> x + acc end)
    6

    iex> Enum.reduce(%{a: 2, b: 3, c: 4}, 0, fn {_key, val}, acc -> acc + val end)
    9

## Reduce as a building block

Reduce (sometimes called fold) is a basic building block in functional
programming. Almost all of the functions in the Enum module can be implemented
on top of reduce. Those functions often rely on other operations, such as
Enum.reverse/1, which are optimized by the runtime.

For example, we could implement map/2 in terms of reduce/3 as follows:

    def my_map(enumerable, fun) do
      enumerable
      |> Enum.reduce([], fn x, acc -> [fun.(x) | acc] end)
      |> Enum.reverse()
    end

In the example above, Enum.reduce/3 accumulates the result of each call to fun
into a list in reverse order, which is correctly ordered at the end by calling
Enum.reverse/1.

Implementing functions like map/2, filter/2 and others are a good exercise for
understanding the power behind Enum.reduce/3. When an operation cannot be
expressed by any of the functions in the Enum module, developers will most
likely resort to reduce/3.
*/
```


```elixir
iex()> h Enum.reduce/2
```
```c
/*
                          def reduce(enumerable, fun)

  @spec reduce(t(), (element(), acc() -> acc())) :: acc()

Invokes fun for each element in the enumerable with the accumulator.

Raises Enum.EmptyError if enumerable is empty.

The first element of the enumerable is used as the initial value of the
accumulator. Then, the function is invoked with the next element and the
accumulator. The result returned by the function is used as the accumulator for
the next iteration, recursively. When the enumerable is done, the last
accumulator is returned.

Since the first element of the enumerable is used as the initial value of the
accumulator, fun will only be executed n - 1 times where n is the length of the
enumerable. This function won't call the specified function for enumerables
that are one-element long.

If you wish to use another value for the accumulator, use Enum.reduce/3.

## Examples

    iex> Enum.reduce([1, 2, 3, 4], fn x, acc -> x * acc end)
    24
*/
```

map, filter & reduce - это самые распространённые и часто используемые hof,
используются практически в любом проекте. В стандартной либе Elixir есть и
другие функции высшего порядка и об этом будет позже.




## 03 Модуль Enum

- Модуль Enum - это модуль для работы с коллекциями. Название по сути не лучшее.
Так как в большинстве ЯП(языков программирования) Enum это "перечисление",
имеющее ограниченное кол-во значений. В Elixir же модуль Enum собирает в себе
функции для работы с **любыми** коллекциями. То есть по идеи более правильное
название было бы `Collection` а не Enum.

### Что такое коллекции?

В Elixir коллекциями являются:
- List
- Map
- Range
- Tuple
- String

В Elixir очень многие типы данных являются коллекциями, И модуль Enum умеет
работать со всеми этими коллекциями унифицировано. Как он это делает?

Elixir имеет такую вещь как Протокол(Protocol). Об этом подробно будет позже
пока можно сказать что протокол это нечто похожее на interface в Java.
То есть протокол - это некое соглашение о чётко заданном наборе функций,
которые обязательно должны быть реализованы в неком типе данных.
(в java это методы в классе) Так чтобы после этот набор функций можно было
одинаково работать с этими типами данных.

### Protocol Enumerable
- это набор неких чётко заданных функций, которые реализуются во таких типах
данных как List, Map, Range, Tuple и т.д вызывая которые модуль Enum сможет
работать со всеми этими разными типами данных, одинаково, представляя их себе
как некие абстрактные коллекции.
То есть протоколы в Elixir - это способ реализации полиморфизма.


### Enum.sort Сортировка.

Говоря о типах данных было сказано, что
- сортировка определена для всех типов
- есть некий порядок сортировки, так что любой тип данных можно сравнивать с
  любым другим типом данных. (Например number < atom < reference < function ...)
поэтому можно вызывать Enum.sort на любой коллекции

```elixir
iex(19)> Enum.sort([1,5,3])
[1, 3, 5]

iex(20)> Enum.sort([1,"hh",fn a -> a end, {:a, :b}])
[1, #Function<42.105768164/1 in :erl_eval.expr/6>, {:a, :b}, "hh"]
```

То есть Enum.sort умеет сортировать вообще любые типы данных даже перемешанные
между собой в одной и той же коллекции.

Но обычно стоит задача сортировать коллекцию неких однородных объектов предметной
области (своих типов данных), например пользователей. А значит часто нужно самому
указывать как именно сравнивать свои типы данных и объекты предметной области.
Поэтому есть и Enum.sort/2 вторым аргом принимающий сортирующую функцию.
Через неё можно указать как именно сравнивать наши объекты (свои типы данных)


```sh
cd 06-hof
iex
```
```elixir
iex(1)> c "hof.exs"
[HOF]

iex(2)> users = HOF.test_data
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

iex(3)> Enum.sort(users)
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
```
как видем по умолчанию ничего не меняется.


сортировка по имени
```elixir
iex(4)> sorter = fn {:user, _, name1, _}, {:user, _, name2, _} -> name1 > name2 end
#Function<41.105768164/2 in :erl_eval.expr/6>

iex(6)> Enum.sort(users, sorter)
[
  {:user, 5, "Yura", 31},
  {:user, 7, "Yana", 35},
  {:user, 4, "Kate", 11},
  {:user, 3, "Helen", 10},
  {:user, 6, "Dima", 65},
  {:user, 8, "Diana", 41},
  {:user, 1, "Bob", 15},
  {:user, 2, "Bill", 25}
]
```

### sort_by_attr

Пример написания функции для сортировки пользователей по указанному атрибуту.
Так чтобы можно было задать атрибут по которому дальше наша функция будет
сортировать коллекцию пользователей.

```elixir
defmodule HOF do
  # ...

  def sort_by_attr(users, attr) do
    # ...
  end
end
```

- users - коллекция пользователей которую нужно  отсортировать
- attr - имя атрибута по которому нужно отсортировать.
  Здесь attr - это уже настоящее перечисление(Enum) то есть ограниченный набор
  значений, в нашем случае это :id, :name, :age

Для наглядности определим тип этого перечисления, чтобы это было видно из кода.
А так же опишем(зададим) свои типы данных (для user - обьектов предметной области)

- @type attr_type
- @spec - для определения типов сигнатуры функции (спецификация функции)
  через эту вещь можно указать типы принимаемых и возвращаемого значений



```elixir
defmodule HOF do
  # ...

  @type user :: {:user, integer(), String.t(), integer()}
  @type attr_type :: :id | :name | :age

  @spec sort_by_attr([user()], attr_type()) :: [user()]
  def sort_by_attr(users, attr) do
    # ...
  end
end
```

@spec - это спецификация, позволяющая явно указать используемые типы
Elixir - это язык с динамической типизацией, но в нём есть возможность описывать
(define) пользовательские типы данных или использовать встроенные типы данных
integer() - для целочисленных чисел, String.t() - строк

Спецификация упрощает понимание кода программистами(документирование кода),
и так же может использоваться статическими анализаторами кода.
Один из таких - это инструмент Dializer.

здесь мы обьявили свой тип данных `user`
```elixir
@type user :: {:user, integer(), String.t(), integer()}
#     1       ^                 2                     ^
#                ^3      ^4        ^5           ^6
```
- 1 - Имя типа данных, на который можно будет ссылаться
- 2 - это кортеж из 4 значений, первое из которых это всегда один и тот же атом
    `:user`
- 4 - второй элемент в кортеже типа integer (id)
- 5 - 3й элемент строка (name)
- 6 - 4й -элемент число (age)


Вот это способ как задать "настоящее перечисление".
```elixir
@type attr_type :: :id | :name | :age
```
то есть тип attr_type может быть одним из заданных атомов :id :name или :age


```elixir
@spec sort_by_attr([user()], attr_type()) :: [user()]
#        1            2         3               4
```
- 1. название функции для которой описана эта спецификация
- 2. 1й аргумент функции это коллекция из элементов с нашим типом user
- 3. 2й аргумент - перечисление одно из значений :id :name :age
- 4. возвращаемое значение - коллекция пользователей (наш тип)

Как итог того, что описали спецификацию для sort_by_attr:

```elixir
defmodule HOF do
  # ...

  @type user :: {:user, integer(), String.t(), integer()}
  @type attr_type :: :id | :name | :age

  @spec sort_by_attr([user()], attr_type()) :: [user()]
  def sort_by_attr(users, attr) do
    # ...
  end
end
```
это очень удобное и универсальное документирование типов с которыми работает
функция sort_by_attr. Тоже самое можно было бы например долго и развесисто
описать словами в StringDoc блоке документации. Но это более ёмкий, простой и
быстрый способ сделать это проще и нагляднее.


#### Пишем сортирующую функцию
более удобно это можно сделать через фишку языка Elixir для паттерн матчинга
на уровне сигнатур функций.
ТО есть да можно было бы эту сортирующую функцию сделать одну, а можно просто
сразу сделать 3 её варианта по attr_type:

```elixir
defmodule HOF do
  @type user :: {:user, integer(), String.t(), integer()}
  @type attr_type :: :id | :name | :age

  @spec sort_by_attr([user()], attr_type()) :: [user()]
  def sort_by_attr(users, attr) do
    sorter =
      case attr do
        :id -> &compare_by_id/2
        :name -> &compare_by_name/2
        :age -> &compare_by_age/2
      end
    Enum.sort(users, sorter)
  end

  def compare_by_id(user1, user2) do
    {:user, id1, _, _} = user1
    {:user, id2, _, _} = user2
    id1 < id2
  end

  def compare_by_name(user1, user2) do
    {:user, _, name1, _} = user1
    {:user, _, name2, _} = user2
    name1 < name2
  end

  def compare_by_age(user1, user2) do
    {:user, _, _, age1} = user1
    {:user, _, _, age2} = user2
    age1 < age2
  end
end
```

```elixir
iex(7)> r HOF
{:reloaded, [HOF]}

iex(8)> HOF.sort_by_attr(users, :age)
[
  {:user, 3, "Helen", 10},
  {:user, 4, "Kate", 11},
  {:user, 1, "Bob", 15},
  {:user, 2, "Bill", 25},
  {:user, 5, "Yura", 31},
  {:user, 7, "Yana", 35},
  {:user, 8, "Diana", 41},
  {:user, 6, "Dima", 65}
]

iex(9)> HOF.sort_by_attr(users, :name)
[
  {:user, 2, "Bill", 25},
  {:user, 1, "Bob", 15},
  {:user, 8, "Diana", 41},
  {:user, 6, "Dima", 65},
  {:user, 3, "Helen", 10},
  {:user, 4, "Kate", 11},
  {:user, 7, "Yana", 35},
  {:user, 5, "Yura", 31}
]

iex(10)> HOF.sort_by_attr(users, :id)
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
```


## sort_by_attr Направление сортировки

3й аргумент для sort_by_attr, задающий направление для сортировки - по убыванию
или по возрастанию.
Можно было просто скопипастить код поменяв знак < на >, но есть способ и получше

Можно поступить мудрее, используя возможности функционального языка и HOF.
HOF Это и про то, что функции можно передавать в другие функции в виде аргумента.
и еще когда функция возращает другую функцию. Вообще код в котором одна ф-я
возращает другую функцию достаточно редкое явление. бывает так что на практике
с этим и не сталкиваются, но знать об этом надо.

Пишем функцию инвентер.

Принимает одну функцию а возвращает инвертированное значение

```elixir
  def invertor(predicate) do
    fn arg1, arg2 -> not predicate.(arg1, arg2) end
  end
```
Здесь
- predicate - это ссылка на функцию
- predicate.(arg1, arg2) - это вызов функции
- сама фун-я invertor возвращает другую функцию

Обновляем код сортировки добавяля еще и направление сортировки.

```elixir
  @type user :: {:user, integer(), String.t(), integer()}
  @type attr_type :: :id | :name | :age
  @type direction :: :arc | :desc

  @spec sort_by_attr([user()], attr_type(), direction()) :: [user()]
  def sort_by_attr(users, attr, direction) do
    sorter =
      case {attr, direction} do
        {:id, :asc} -> &compare_by_id/2
        {:id, :desc} -> invertor(&compare_by_id/2)
        {:name, :asc} -> &compare_by_name/2
        {:name, :desc} -> invertor(&compare_by_name/2)
        {:age, :asc }-> &compare_by_age/2
        {:age, :desc }-> invertor(&compare_by_age/2)
      end
    Enum.sort(users, sorter)
  end

  def compare_by_id(user1, user2) do
    {:user, id1, _, _} = user1
    {:user, id2, _, _} = user2
    id1 < id2
  end

  def compare_by_name(user1, user2) do
    {:user, _, name1, _} = user1
    {:user, _, name2, _} = user2
    name1 < name2
  end

  def compare_by_age(user1, user2) do
    {:user, _, _, age1} = user1
    {:user, _, _, age2} = user2
    age1 < age2
  end

  def invertor(predicate) do
    fn arg1, arg2 -> not predicate.(arg1, arg2) end
  end
```

```elixir
iex()> r HOF
iex()> HOF.sort_by_attr(users, :id, :desc)
[
  {:user, 8, "Diana", 41},
  {:user, 7, "Yana", 35},
  {:user, 6, "Dima", 65},
  {:user, 5, "Yura", 31},
  {:user, 4, "Kate", 11},
  {:user, 3, "Helen", 10},
  {:user, 2, "Bill", 25},
  {:user, 1, "Bob", 15}
]

iex()> HOF.sort_by_attr(users, :id, :asc)
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

iex()> HOF.sort_by_attr(users, :age, :asc)
[
  {:user, 3, "Helen", 10},
  {:user, 4, "Kate", 11},
  {:user, 1, "Bob", 15},
  {:user, 2, "Bill", 25},
  {:user, 5, "Yura", 31},
  {:user, 7, "Yana", 35},
  {:user, 8, "Diana", 41},
  {:user, 6, "Dima", 65}
]
iex()> HOF.sort_by_attr(users, :age, :desc)
[
  {:user, 6, "Dima", 65},
  {:user, 8, "Diana", 41},
  {:user, 7, "Yana", 35},
  {:user, 5, "Yura", 31},
  {:user, 2, "Bill", 25},
  {:user, 1, "Bob", 15},
  {:user, 4, "Kate", 11},
  {:user, 3, "Helen", 10}
]
```

Как результат у нас есть функция сортировки пользователей по любому из атрибутов
еще и с возможностью сортировки по разным направлениям(по возрастанию(:asc) и
убыванию(:desc)



### Enum.zip объединение нескольких коллекций в одну

```elixir
iex(20)> ids = [10, 20, 30, 40, 50]
[10, 20, 30, 40, 50]

iex()> Enum.zip(users, ids)
[
  {{:user, 1, "Bob", 15}, 10},
  {{:user, 2, "Bill", 25}, 20},
  {{:user, 3, "Helen", 10}, 30},
  {{:user, 4, "Kate", 11}, 40},
  {{:user, 5, "Yura", 31}, 50}
]

iex()> Enum.zip(ids, users)
[
  {10, {:user, 1, "Bob", 15}},
  {20, {:user, 2, "Bill", 25}},
  {30, {:user, 3, "Helen", 10}},
  {40, {:user, 4, "Kate", 11}},
  {50, {:user, 5, "Yura", 31}}
]
```

Как видно zip заканчивает работу на коротком списке

пример замены Id-шников из другой коллекции.
```elixir
zipper = fn id, {:user, _, name, age} -> {:user, id, name, age} end
#Function<41.105768164/2 in :erl_eval.expr/6>

iex(24)> Enum.zip_with(ids, users, zipper)
[
  {:user, 10, "Bob", 15},
  {:user, 20, "Bill", 25},
  {:user, 30, "Helen", 10},
  {:user, 40, "Kate", 11},
  {:user, 50, "Yura", 31}
]
```


### Enum.group_by

Для разбития коллекции на группы по некому условию. Результатом будет несколько
списков по количеству групп. В каждой группе свои элементы. Похожий пример было
разделение пользователей по возрасту (split_by_age). Там было две группы и
группировка(разделение) шла по возрасту. group_by же позволяет делить на любое
нужное количество групп.

grouper - эта фун-я которая просто возращает атомы(имена) групп
и результатом работы будет несколько списков в мапе с заданными именами групп

```elixir
 def group_users(users) do
    grouper = fn {:user, _, _, age} ->
      cond do
        age <= 14 -> :child
        age > 14 and age < 18 -> :ten
        age > 18 and age <= 60 -> :adult
        true -> :old
      end
    end

    Enum.group_by(users, grouper)
  end
```

```elixir
iex()> r HOF
{:reloaded, [HOF]}

iex()> HOF.group_users(users)
%{
  child: [{:user, 3, "Helen", 10}, {:user, 4, "Kate", 11}],
  old: [{:user, 6, "Dima", 65}],
  ten: [{:user, 1, "Bob", 15}],
  adult: [
    {:user, 2, "Bill", 25},
    {:user, 5, "Yura", 31},
    {:user, 7, "Yana", 35},
    {:user, 8, "Diana", 41}
  ]
}
```


## Кратко о других функциях из модуля Enum

- Enum.all?/1 проверят что все элементы коллекции truthy (not flase & not nil)
- Enum.all?/2 - 2й арг. кастомная функция проверяющая на truthy/falsy

- Enum.any?/1,2 любой элемент коллекции truthy
- Enum.count/1,2 подсчёт эл-тов в коллекции, 2 - для которых ф-я возращает true
- Enum.drop/2 - отбросить некое кол-во в коллекции
- Enum.drop_while - обрежет коллекцию до первого falsy
- Enum... есть и другие HOF функции смотри доку.

- Map - тоже содержит HOF функции, но для работы с Map-ами
- Map.filter/2 - фильтрация
- Map.merge/2 - слияние двух мап в одну
- Map.merge/3 - 3й это функция разруливающая конфликты. выбирает из 2х одно знач.
- Map.split_with/2 делит мапу на несколько по заданному условию

- Keyword - похожие функции как в Map но не для мап а для key=value списками

- List.foldl List.foldr  List.foldl это аналог Enum.reduce
  правая свёртка - идёт от хвоста к голове
  левая - от головы к хвосту (списка)




## 06.04. Конструкторы списков - List Comprehension

Еще одна фича Elixir, которая хотя и используется редко, но даёт некие удобные
вещи которых нет ни у HOF ни у модуля Enum

```sh
iex hof.exs
```

```elixir
iex()> users = HOF.test_data
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
```



```elixir
iex()> for user <- users, do: user
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
```

```elixir
for user <- users, do: user
#   ^2^     ^^1^^      ^3^^
```
Внешне это чем-то похоже на цикл for, но это штука называется конструктор списков
На деле это спец. конструкция языка которая:
- 1. как input принимает один или несколько списков
- 2. что-то делает с элементами через паттерн-матчинги и фильтры
- 3. на выходе отдаёт некий новый список

Пример построителя списков
```elixir
iex()> for {:user, id, name, _} <- users, do: {id, name}
#          ^^^^^^^^^^1^^^^^^^^                ^^^^2^^^^
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
Примерно тоже самое мы раньше уже делали через Enum.map

- 1. через паттерн-матчинг извлекает данные из каждого элемента коллекции
- 2. формируем очередной элемент для результирующей коллекции

добавляем фильтрацию

```elixir
iex()> for {:user, id, name, age} <- users, age > 16, do: {id, name, age}
#                                            ^^^^^^^^ predicate
[
  {2, "Bill", 25},
  {5, "Yura", 31},
  {6, "Dima", 65},
  {7, "Yana", 35},
  {8, "Diana", 41}
]
```

```elixir
iex()> for {:user, id, name, age} = user <- users, age > 16, do: user
#                                            ^^^^^^^^ predicate
[
  {2, "Bill", 25},
  {5, "Yura", 31},
  {6, "Dima", 65},
  {7, "Yana", 35},
  {8, "Diana", 41}
]
```

если нужно просто отфильтровать не изменяя сами элементы коллекции
(т.е. добавлять user как есть)
```elixir
iex(5)> for {:user, _id, _name, age} = user <- users, age > 16, do: user
#                                    ^^^^^^                         ^^^^
[
  {:user, 2, "Bill", 25},
  {:user, 5, "Yura", 31},
  {:user, 6, "Dima", 65},
  {:user, 7, "Yana", 35},
  {:user, 8, "Diana", 41}
]
```

То есть через одну конструкцию - за один проход можно выполнить сразу два действия
- маппинг (преобразовать элемент вытащив какие-то части элемента)
- фильтрацию (откинуть не нужные по некому условию)


#### работа с несколькими списками одновременно

берём два списка и за один обход строим новый список, сопоставление
"каждый с каждым"

```elixir
iex()> list1 = [1, 2, 3, 4]
[1, 2, 3, 4]

iex()> list2 = [:a, :b, :c, :d]
[:a, :b, :c, :d]

iex()> for x <-list1, y <- list2, do: {x, y}
[
  {1, :a},
  {1, :b},
  {1, :c},
  {1, :d},
  {2, :a},
  {2, :b},
  {2, :c},
  {2, :d},
  {3, :a},
  {3, :b},
  {3, :c},
  {3, :d},
  {4, :a},
  {4, :b},
  {4, :c},
  {4, :d}
]
```

```elixir
iex()> list3 = ["x", "y"]
["x", "y"]

iex()> for x <-list1, y <- list2, z <-list3, do: {x, y, z}
[
  {1, :a, "x"},
  {1, :a, "y"},
  {1, :b, "x"},
  {1, :b, "y"},
  {1, :c, "x"},
  {1, :c, "y"},
  {1, :d, "x"},
  {1, :d, "y"},
  {2, :a, "x"},
  ...
  {4, :d, "y"}
]
```

к этому еще и предикаты можно добавлять

```elixir
iex()> for x <-list1, y <- list2, z <-list3, x > 2, do: {x, y, z}
#                                            ^^^^^^
[
  {3, :a, "x"},
  {3, :a, "y"},
  {3, :b, "x"},
  {3, :b, "y"},
  {3, :c, "x"},
  {3, :c, "y"},
  {3, :d, "x"},
  {3, :d, "y"},
  {4, :a, "x"},
  {4, :a, "y"},
  {4, :b, "x"},
  {4, :b, "y"},
  {4, :c, "x"},
  {4, :c, "y"},
  {4, :d, "x"},
  {4, :d, "y"}
]
```
предикатов тоже может быть более одного

```elixir
iex()> for x <-list1, y <- list2, z <-list3, x > 2, y != :b, do: {x, y, z}
#                                                     ^^^^^^^
[
  {3, :a, "x"},
  {3, :a, "y"},
  {3, :c, "x"},
  {3, :c, "y"},
  {3, :d, "x"},
  {3, :d, "y"},
  {4, :a, "x"},
  {4, :a, "y"},
  {4, :c, "x"},
  {4, :c, "y"},
  {4, :d, "x"},
  {4, :d, "y"}
]

iex()> for x <-list1, y <- list2, z <-list3, x > 2,y != :b, z == "y", do: {x, y, z}
#                                                           ^^^^^^^
[
  {3, :a, "y"},
  {3, :c, "y"},
  {3, :d, "y"},
  {4, :a, "y"},
  {4, :c, "y"},
  {4, :d, "y"}
]
```

фильтровать входные списки можно не только по предикатам, но и по
паттерн-матчингу. Если очередной элемент входного списка не проходит маттчинг то он сразу откидывается
```elixir
iex()> lions = [
...()> {:lion, 10, "Nemean", 29},
...()> {:lion,  11, "Cithaeron", 45}
...()> ]
[{:lion, 10, "Nemean", 29}, {:lion, 11, "Cithaeron", 45}]

iex()> users_and_lions = users ++ lions
[
  {:user, 1, "Bob", 15},
  {:user, 2, "Bill", 25},
  {:user, 3, "Helen", 10},
  {:user, 4, "Kate", 11},
  {:user, 5, "Yura", 31},
  {:user, 6, "Dima", 65},
  {:user, 7, "Yana", 35},
  {:user, 8, "Diana", 41},
  {:lion, 10, "Nemean", 29},
  {:lion, 11, "Cithaeron", 45}
]

# unchanged
iex()> for item <- users_and_lions, do: item
[
  {:user, 1, "Bob", 15},
  {:user, 2, "Bill", 25},
  {:user, 3, "Helen", 10},
  {:user, 4, "Kate", 11},
  {:user, 5, "Yura", 31},
  {:user, 6, "Dima", 65},
  {:user, 7, "Yana", 35},
  {:user, 8, "Diana", 41},
  {:lion, 10, "Nemean", 29},
  {:lion, 11, "Cithaeron", 45}
]

# lions are filtered
iex()> for {:user, _, _, _} = item <- users_and_lions, do: item
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
```


То есть построитель списков даёт возможность строить список выбирая сразу и
одновременно по нескольким спискам любой длинны еще и по нескольким предикатам.


#### формальный синтаксис конструктора списков

Абстрактный вид синтаксиса конструктора списков
```c
/*
for
  generator1, generator2, generatorN,
  fileter1, filter2, filterN,
  into: destination,
  do: result_item

generator: pattern <- list

filter: predicate
into: куда вставлять элементы
do: формаирование каждого элемента
*/
```
- в generator если очередной элемент не проходит паттер-матчинг как в пример выше
со львами, то такой элемент сразу отбрасывается и не идёт в результ. список.
- into - позволяет задать коллекцию куда вставлять выходные значения.
(если его нет создаёт новый список)

- do - здесь описывается построение каждого выходного элемента, который будет
  добавлен в результирующий выходной список, или коллекцию указанную в into:


вот пример вставки в уже существующую мапу data


```elixir
iex()> data = %{a: 100, b: 200, g: 300}
%{a: 100, b: 200, g: 300}

iex()> list_1 = [1, 2, 3]
[1, 2, 3]

iex()> list_2 = [:a, :b, :d]
[:a, :b, :d]

iex()> for x <- list_1, y <- list_2, do: {x, y}
[
  {1, :a},
  {1, :b},
  {1, :d},
  {2, :a},
  {2, :b},
  {2, :d},
  {3, :a},
  {3, :b},
  {3, :d}
]

iex(12)> for x <- list_1, y <- list_2, do: {y, x}
[a: 1, b: 1, d: 1, a: 2, b: 2, d: 2, a: 3, b: 3, d: 3]

iex(13)> for x <- list_1, y <- list_2, into: data, do: {y, x}
%{a: 3, d: 3, b: 3, g: 300}
```

### Пример из книги Джо Армстронга Пифагоровы тройки.

Задача:
для заданной длинны, найти все пары катетов и гипотенуз которые илюстрируя
теорему Пифагора в целых числах.
Классический пример такой тройки катеты 3 и 4 и гипотенуза 5.
для длинны 13 появится еще одна тройка: катеты 5 и 12, гипотенуза 13
катеты 6 и 8, гипотенуза 10. То есть суть задачи - для максимальной длинны
найти все возможные Пифагоровы тройки


```elixir
iex()> max_length = 20
20

iex()> lengths = 1..20
1..20

iex()> for x <- lengths, do: x
[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]

iex()> for x <- lengths, y <- lengths, z <- lengths, do: {x, y, z}
[
  {1, 1, 1},
  {1, 1, 2},
  {1, 1, 3},
  {1, 1, 4},
  ...
]
```
отсекаем всё лишнее оставляя только пифагоровы тройки
```elixir
iex()> for x <- lengths, y <- lengths, z <- lengths, x*x+y*y==z*z, do: {x, y, z}
[
  {3, 4, 5},
  {4, 3, 5},
  {5, 12, 13},
  {6, 8, 10},
  {8, 6, 10},
  {8, 15, 17},
  {9, 12, 15},
  {12, 5, 13},
  {12, 9, 15},
  {12, 16, 20},
  {15, 8, 17},
  {16, 12, 20}
]
```
отсекаем дублирование длинн катетов (3,4,5} {4,3,5}
```elixir
iex()> for x <- lengths, y <- lengths, z <- lengths, x*x+y*y==z*z, x < y, do: {x, y, z}
[
  {3, 4, 5},
  {5, 12, 13},
  {6, 8, 10},
  {8, 15, 17},
  {9, 12, 15},
  {12, 16, 20}
]
```

пример как можно задать другой диапазон внутри которого нужно найти пифагоровы тройки
```elixir
iex(21)> lengths = 1..50
1..50

iex(22)> for x <- lengths, y <- lengths, z <- lengths, x*x+y*y==z*z, x < y, do: {x, y, z}
[
  {3, 4, 5},
  {5, 12, 13},
  {6, 8, 10},
  {7, 24, 25},
  {8, 15, 17},
  {9, 12, 15},
  {9, 40, 41},
  {10, 24, 26},
  ....
  {30, 40, 50}
]
```

Вот и получаем, что используя конструкторы списков можно решать такие сложные
по формулировке задачи одной строкой кода:

```elixir
for x <- lengths, y <- lengths, z <- lengths, x*x+y*y==z*z, x<y, do: {x, y, z}
#   1             1             1             ^^^^2^^^^^^   ^2^      ^^^^3^^^
```
- 1. три элемента из одного спика(lengths)
- 2. два предиката
- 3. элемент тройки

