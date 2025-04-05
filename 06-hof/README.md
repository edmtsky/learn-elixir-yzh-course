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






