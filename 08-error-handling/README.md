## Урок 8 Обработка ошибок

- 08.01 Исключения
- 08.02 Классы исключений
- 08.03 Пользовательские типы исключений
- 08.04 Defensive Programming vs Let It Crash


### Исключения

о том, какие есть механики обработки и генерации исключений.


```elixir
iex> {:ok, _} = {:not_ok, 42}

** (MatchError) no match of right hand side value: {:not_ok, 42}
    (stdlib 5.2) erl_eval.erl:498: :erl_eval.expr/6
    iex:1: (file)
```

MatchError - говорит что значение с права не совпадает со значением с лева.

попытка сложить число с атомом даст ArithmeticError
```elixir
iex> 42 + :a

** (ArithmeticError) bad argument in arithmetic expression: 42 + :a
    :erlang.+(42, :a)
    iex:1: (file)
```

ArithmeticError - неправильное арифметическое выражение

Попытка вызвать не существующую функцию
```elixir
iex> some_non_exists_func()

error: undefined function some_non_exists_func/0 (there is no such import)
└─ iex:1

** (CompileError) cannot compile code (errors have been logged)


# попытка вызвать функцию из не существующего модуля
iex> SomeModule.func(42)

** (UndefinedFunctionError) function SomeModule.func/1 is undefined (module SomeModule is not available). Make sure the module name is correct and has been specified in full (or that an alias has been defined)
    SomeModule.func(42)
    iex:1: (file)
```

Можно еще вызывать функции динамически через функцию apply
```elixir
iex> apply(SomeModule, :some_func, [42])
** (UndefinedFunctionError) function SomeModule.some_func/1 is undefined (module SomeModule is not available). Make sure the module name is correct and has been specified in full (or that an alias has been defined)
    SomeModule.some_func(42)
    iex:1: (file)
```


### raise - генерация исключений

"кидаем" исключение RuntimeError:

```elixir
iex> raise(RuntimeError)
** (RuntimeError) runtime error
    iex:1: (file)

# добавление сообщения в сиключение
iex> raise(RuntimeError, message: "somethig going wrong")
** (RuntimeError) somethig going wrong
    iex:1: (file)

# RuntimeError - исключение по умолчанию, поэтому можно и так:
iex(1)> raise("somethig going wrong")
** (RuntimeError) somethig going wrong
    iex:1: (file)
```

### обработка и перехват исключений

exception_demo.exs
```elixir
defmodule ExceptionDemo do
  def try_rescue() do
    try do
      :a = :b
    rescue
      error -> IO.puts("unknown error #{inspect(error)}")
    end
  end
end
```

```sh
iex exception_demo.exs
```

кидает варниг т.к. знает еще на этапе компиляции что здесь будет исключение
```elixir
 warning: the following pattern will never match:

        :a = :b

    because the right-hand side has type:

        :b

    typing violation found at:
    │
  5 │       :a = :b
    │          ~
    │
    └─ exeption_demo.ex:5:10: ExceptionDemo.try_rescue/0
```

```elixir
iex> alias ExceptionDemo, as: E
ExceptionDemo

iex> E.try_rescue
unknown error %MatchError{term: :b}
:ok
```

### перехват конкретных исключений через guard-ы

это про то как в своём коде перехватывать разные исключения
нечто вроде веток
если такое-то исключение тогда делаем сё, если другое то что-то еще


```elixir
defmodule ExceptionDemo do
  def try_rescue() do
    try do
      :a = :b   # кинет MatchError
    rescue
      error in [MatchError, ArithmeticError] -> # guard для перехватки исключ.
        IO.puts("clause 1, MatchError or ArithmenicError #{inspect(error)}")

      error in [RuntimeError] ->
        IO.puts("clause 2, RuntimeError #{inspect(error)}")

      error ->
        IO.puts("clause 3, unknown error #{inspect(error)}")
    end
  end
end
```

```elixir
iex r E   # перекомпиляция(r) модуля ExceptionDemo по алиасу E

# запуск
iex> E.try_rescue
clause 1, MatchError or ArithmenicError %MatchError{term: :b}
:ok
```

изменяю код чтобы кинуло другое исключение
```elixir
# :a = :b   # кинет MatchError
42 + :a
```

```elixir
iex> r E

iex> E.try_rescue
clause 1, MatchError or ArithmenicError %ArithmeticError{message: "bad argument in arithmetic expression"}
:ok
```

```elixir
   # 42 + :a
   raise("Somethign happend")
```

```elixir
iex> r E

iex> E.try_rescue
clause 2, RuntimeError %RuntimeError{message: "Somethign happend"}
:ok
```

```elixir
    # raise("Somethign happend")
    SomeModule.some(42)
```

```elixir
r E
    warning: SomeModule.some/1 is undefined (module SomeModule is not available or is yet to be defined). Make sure the module name is correct and has been specified in full (or that an alias has been defined)
    │
  8 │       SomeModule.some(42)
    │                  ~
    │
    └─ exeption_demo.exs:8:18: ExceptionDemo.try_rescue/0

{:reloaded, [ExceptionDemo]}
iex> E.try_rescue
clause 3, unknown error %UndefinedFunctionError{module: SomeModule, function: :some, arity: 1, reason: nil, message: nil}
:ok
```


#### блок after в перехвате исключений
это аналог блока finally в Java
этот блок выполняется всегда не зависимо от того было исключение или нет.

```elixir
defmodule ExceptionDemo do
  def try_rescue() do
    try do
      # :a = :b
      # 42 + :a
      # raise("Somethign happend")
      SomeModule.some(42)
    rescue
      error in [MatchError, ArithmeticError] ->
        IO.puts("clause 1, MatchError or ArithmenicError #{inspect(error)}")

      error in [RuntimeError] ->
        IO.puts("clause 2, RuntimeError #{inspect(error)}")

      error ->
        IO.puts("clause 3, unknown error #{inspect(error)}")
    after                                # +++
      IO.puts("after is always called")  # +++
    end
  end
end
```

```elixir
iex> r E
iex> E.try_rescue
clause 3, unknown error %UndefinedFunctionError{module: SomeModule, function: :some, arity: 1, reason: nil, message: nil}
after is always called                      ## сработал after("finally") блок
:ok
```


#### соглашение именования функций которые бросают исключения
По соглашению наименования функций - добавляем `!` в конец для функций кидающих
исключения

в Elixir есть функции для двух подходов, для работы исключительных ситуаций
через кортежи и атомы :ok :error и теже но с `!` которые бросают исключения:

 ```elixir
iex> m = %{a: 42}
%{a: 42}

iex> Map.fetch(m, :a)
{:ok, 42}

iex> Map.fetch(m, :k)
:error

iex> Map.fetch!(m, :a)
42

iex> Map.fetch!(m, :k)
** (KeyError) key :k not found in: %{a: 42}
    (stdlib 5.2) :maps.get(:k, %{a: 42})
    iex:17: (file)
```

- Map.fetch - не бросает исключение, результат обёрнут в кортеж с :ok, :error
- Map.fetch! - бросает исклюение если ключа нет, иначе сразу само значение.

вот еще пример:

```elixir
iex> File.read("exeption_demo.exs")
{:ok, "содержимое файла в виде строки"}

iex> File.read("exeption_demo.exsXXX")
{:error, :enoent}

iex> File.read!("exeption_demo.exs")
"содержимое файла в виде строки"

iex> File.read!("exeption_demo.exsXXX")
** (File.Error) could not read file "exeption_demo.exsXXX": no such file or directory
    (elixir 1.18.3) lib/file.ex:385: File.read!/1
    iex:4: (file)
```


#### использование исключения для control flow

в разных языках используются разные идеалогии и реализации
в некоторых языках считается нормальным использовать control flow
(а конкретнее исключения) для управления потоком выполнения кода на ровне
с такими вещами как if, switch и pattern-matching в Elixir
яркий пример такого языка - Python, в нём исключения "на каждом шагу" везде
в том числе и в библиотечных функциях. Даже в Iteration протоколе(интерфейсе)
инфа о том, что элементы в коллекции закончились(метод `next()`) и тот передаётся
через исключение

есть и другие языки в которых считается, что исключение это что-то не штатное
и не годятся для управления потоком выполнения кода. а если исключение случилось
то программа должна отрапортовать упасть и завершиться - так в языке Rust.
В Rust нет исключений, в нём есть "паника". Панику перехватить нельзя и если
такая "паника"(исключение) случилось то текущий процесс завершается.
ТО есть в Rust нельзя использовать исключения для управления потоком выполнения
кода, для этого нужно использовать другие средства.

В Elixir есть и те и другие средства.
- можно использовать исключения для ControlFlow
- можно и не использовать

но вообще исключение считается тяжелой для VM операцией и делать ControlFlow
на них не рекомендуется

в Erlang исключения для ControlFlow используются крайне редко, в Elixr как-то
почаще, но всё равно лучше этого избегать в своём коде. В Elixir для этого
есть и другие удобные механизмы, чтобы не использовать одни только исключения.



## 08.02 Классы исключений

курьёзная тонкость про перехват исключений
который способ удивить при попытке отловить исключения, особенно в проде

есть два способа "бросить" исключение: raise и throw

```elixir
iex> raise "boom!"
** (RuntimeError) boom!
    iex:1: (file)

iex> throw "boom!2"
** (throw) "boom!2"
    iex:1: (file)
```

и есть два способа "ловить"(перехватывать) исключения: try-rescue & try-catch

почему два способа кидать и ловить исключения?
Опять Эрланг... В самой VM работает система исключений сделанная для Erlang-а
Elixir поверх системы исключений Erlang построил свою систему исключений, но
в некоторых моментах эрланговская система исключений "вылезает наружу" и
причиняет "боль" тем, кто про неё не знает.

- raise + try-rescue - это Elixir-овские исключения и способ их словить
- throw + try-catch  - это Erlang-овские


#### как устроена система исключений в Erlang

есть три класса исключений:

Exception classes(types) (Erlang):
- :throw - уровень бизнес логики - что-то кастомное для программиста
  их можно кидать и перехватывать в своём коде для ControlFlow но так делать
  не рекомендуется.
- :error - exceptional situations like panic
  бросать можно, но перехватывать нет (технически можно, идеологически не надо).
- :exit - это про многопоточку и взаимодействие Erlang-процессов друг с другом

throw - позволяет кинуть эрланговское исключени
может принимать значение любого типа хоть число хоть список:
```elixir
iex> throw(42)
** (throw) 42
    iex:1: (file)

iex> throw([1,2,3])
** (throw) [1, 2, 3]
    iex:1: (file)
```

:erlang.error - чтобы кинуть исключения класса Error

```elixir
iex> :erlang.error(42)
** (ErlangError) Erlang error: 42
    iex:1: (file)

iex> :erlang.error("boom!")
** (ErlangError) Erlang error: "boom!"
    iex:1: (file)
```

на деле throw тоже находится в модуле :erlang, просто она импортирована не явно
поэтому можно обращаться напрямую.(без имени модуля) и доступ упрощен для
удобства


####  системе исключений в Elixir

эликсир строит свою систему исключений поверх Эрланговской системы
за основу бируться исключения класса(типа) :error, которые по идеи в Erlang
должны быть panic-ой. Но в Elixir игнорируется эта идея, и поверх :error
строится своя система исключений, которые обрабатываются через raise/try-rescue

- :error - raise / rescue
- :throw - throw / catch
  осталось от Эрланга, и сам эликсировский код по идеи не должен
  применять :throw, но оно может выскочить в эрланговских либах
- :exit  - ... / catch

Вот и получается что Эликсир поменял идеологию :error(panic) исключений и
использует поверх них свои исключения для ControlFlow, а остальные две:
:exit и :throw и не хотел бы применять но они достались в наследство от ерланг
и никуда от них не деться, т.к. могут "просачиваються" из эрланговских либ.


####  как всё это использовать на практике

функция генерирующая разные исключения

./exception_demo.exs
```elixir
defmodule ExceptionDemo do
  def try_rescue(exc_type) do
    try do
      generate_exception(exc_type)
    rescue
      error in [MatchError, ArithmeticError] ->
        IO.puts("clause 1, MatchError or ArithmenicError #{inspect(error)}")

      error in [RuntimeError] ->
        IO.puts("clause 2, RuntimeError #{inspect(error)}")

      error ->
        IO.puts("clause 3, unknown error #{inspect(error)}")
    after
      IO.puts("after is always called")
    end
  end

  def generate_exception(:raise), do: raise("something happened")
  def generate_exception(:throw), do: throw("something happened")
  def generate_exception(:error), do: :erlang.error("something happened")
  def generate_exception(:exit), do: exit(:something_happened)
end

```

```elixir
iex> alias ExceptionDemo, as: E
ExceptionDemo

iex> E.try_rescue(:raise)
clause 2, RuntimeError %RuntimeError{message: "something happened"}
after is always called
:ok
```

```elixir
iex> E.try_rescue(:throw)
after is always called                         # block fater
** (throw) "something happened"
    exeption_demo.exs:25: ExceptionDemo.generate_exception/1
    exeption_demo.exs:9: ExceptionDemo.try_rescue/1
    iex:3: (file)
```
это исключени в консоли красное - т.е. оно не было перехвачено внашем коде.
т.е. try-rescue не смог его перехватить
но блок after - сработал

```elixir
iex> E.try_rescue(:error)
clause 3, unknown error %ErlangError{original: "something happened", reason: nil}
after is always called
:ok
```
перехвачено. и тип - ErlangError а не RuntimeError

```elixir
iex> E.try_rescue(:exit)
after is always called                     # block
** (exit) :something_happened
    exeption_demo.exs:27: ExceptionDemo.generate_exception/1
    exeption_demo.exs:9: ExceptionDemo.try_rescue/1
    iex:4: (file)
```
after - сработал, но исключение не было перехвачено в нашем коде.


Выходит что эликсировский try-rescue
может перехватывать
 - raise                - это Эликсировская надстройка над Эрланговским :error
 - :error
но НЕ может перехватить
- :throw
- :exit


```elixir
    try do
      # ...
    catch
      err_type, error ->
      # такой странный паттерн матчинг работает только для try-catch
        IO.puts("...")
    end
```

```elixir
defmodule ExceptionDemo do
  # ...

  def try_catch(exc_type) do
    try do
      generate_exception(exc_type)
    catch
      :throw, error ->
        IO.puts("clause 1, error #{inspect(error)} type :throw")

      :error, error ->
        IO.puts("clause 2, error #{inspect(error)} type :error")

      err_type, error ->
        IO.puts("clause 3, unknown error #{inspect(error)} type #{err_type}")
    after
      IO.puts("after is always called")
    end
  end

  def generate_exception(:raise), do: raise("something happened")
  def generate_exception(:throw), do: throw("something happened")
  def generate_exception(:error), do: :erlang.error("something happened")
  def generate_exception(:exit), do: exit(:something_happened)
end
```

- :raise -> :error
```elixir
iex> E.try_catch(:raise)
clause 2, error %RuntimeError{message: "something happened"} type :error
after is always called
:ok


iex> E.try_catch(:throw)
clause 1, error "something happened" type :throw
after is always called
:ok


iex> E.try_catch(:error)
clause 2, error "something happened" type :error
after is always called
:ok


iex> E.try_catch(:exit)
clause 3, unknown error :something_happened type exit
after is always called
:ok
```
итог:
try-catch перехватывает все 3 эрланговские типы исключений и эликсировское
который по сути надстройка над эрланговским

таким образом эрланговские исключение перехватываются только catch

### мысли о том зачем так сделали
Похоже у авторов эликсира была идея спрятать всю поднаготную эрланговских
исключений :throw,:error, :exit, вообще забыв про :throw и :exit, построив
поверх :error свою систему эликсировских  исключений, и работать только с ней.

В суровой практике же выходит так что да можно работать только с эликсировским
try-rescue, но ровно до тех пор пока не столкнёшься с не перехваченными
эрланговскими исключениями (:throw и :exit)

Чаще всего на этом набивают шишки когда делают GenServer.call где есть таймаут
выбрасывающий эрланговское исключение. Причем вся фишка в том, что можно просто
использовать веб-фреймворк Phoenix и его высокоуровневый код не используя
такие низкоуровневые штуки как GenServer, но исключения эрланга могут долететь
и до твоего кода и пролететь мимо эликсировского rescue

## практика воспроизводим исключения эрлага для GenServer
хотя это тема следующего курса о многопоточности и OTP но эта проблема настолько
распостранена что стоит об этом знать прямо сейчас.

```elixir
defmodule MyGenServer do
  use GenServer  # Базовый модуль для реализации generic серверного поведения
  #   ^ макрос генерирующий дополнительный код нужный для GenServer

  @impl true
  def init(_) do  # реализует GenServer Behaviour
    state = %{}
    {:ok, state}
  end

  @impl true
  def handle_call({:hello, data}, _from, state) do # Обработчик входящий сообщений
    IO.puts("MyGenServer got message :hello with data #{inspect(data)}")
    response = 42
    {:reply, response, state}
  end

  def handle_call(:get_smthg, _from, state) do # Обработчик входящий сообщений
    IO.puts("MyGenServer got message :get_smthg")
    :timer.sleep(6000) # 6 sec, where default timeout to recive reponse is 5sec
    response = 42
    {:reply, response, state}
  end
end
```

```elixir
iex> E.start_server
{:ok, #PID<0.180.0>}
```

отправляем сообщение в запущенный GenServer
```elixir
iex> E.hello
MyGenServer got message :hello with data 100
42

iex(4)> GenServer.call(MyGenServer, :get_smthg)
MyGenServer got message :get_smthg
# Здесь зависает на 5 секнуд после чеко выполдится исключение типа :exit :

** (exit) exited in: GenServer.call(MyGenServer, :get_smthg, 5000)
    ** (EXIT) time out
    (elixir 1.18.3) lib/gen_server.ex:1128: GenServer.call/3
    iex:4: (file)
```
а исключение :exit не будет отловлено через  try-rescue
убеждаемся:



```elixir
defmodule ExceptionDemo do
  # ....

  # Запуск своего GenServer
  def start_server() do
    GenServer.start(MyGenServer, [], name: MyGenServer)
  end

  # Триггерит отправку сообщения :hello
  def hello() do
    GenServer.call(MyGenServer, {:hello, 100})
  end

  # Триггерит отправку сообщения :get_smthg
  def get_smthg() do    # (+++)
    try do
      GenServer.call(MyGenServer, :get_smthg)
    rescue # Наивная попытка перехватить исключение (здесь будет эрланговский :exit
      error ->
        IO.puts("got error #{inspect(error)}")
        {:error, :timeout}
    end
  end
end

defmodule MyGenServer do
  use GenServer  # Базовый модуль для реализации generic серверного поведения
  #   ^ макрос генерирующий дополнительный код нужный для GenServer

  @impl true
  def init(_) do  # реализует GenServer Behaviour
    state = %{}
    {:ok, state}
  end

  @impl true
  def handle_call({:hello, data}, _from, state) do # Обработчик входящий сообщений
    IO.puts("MyGenServer got message :hello with data #{inspect(data)}")
    response = 42
    {:reply, response, state}
  end

  def handle_call(:get_smthg, _from, state) do # Обработчик входящий сообщений
    IO.puts("MyGenServer got message :get_smthg")
    :timer.sleep(6000) # 6 sec, where default timeout to recive reponse is 5sec
    response = 42
    {:reply, response, state}
  end
end
```

проверяем и убеждаемся что это не работает:

```elixir
iex(7)> E.get_smthg
MyGenServer got message :get_smthg
# таймаут на 6 секунд

** (exit) exited in: GenServer.call(MyGenServer, :get_smthg, 5000)
    ** (EXIT) time out
    (elixir 1.18.3) lib/gen_server.ex:1128: GenServer.call/3
    exeption_demo.exs:60: ExceptionDemo.get_smthg/0
    iex:7: (file)
```

исправляю rescue на catch + изменяю паттер на "странный" но рабочий

```elixir
  def get_smthg() do
    try do
      GenServer.call(MyGenServer, :get_smthg)
    # rescue
    catch
      _, error ->                                     # вместо error ->
        IO.puts("got error #{inspect(error)}")
        {:error, :timeout}
    end
  end
```

```elixir
iex> r E                                   # перекомпиляция
{:reloaded, [ExceptionDemo, MyGenServer]}

iex> E.get_smthg
MyGenServer got message :get_smthg
# подвисает на 6 секунд и после выдаёт ошибку:
got error {:timeout, {GenServer, :call, [MyGenServer, :get_smthg, 5000]}}
{:error, :timeout}  # Это значение  которые мы сами и возвращае из своей ф-и
```

Итог - если значешь как работают исключения в Erlang и Elixir и то, что
исключения можно ловить и с помощью try-rescue И с помощью try-catch то
в нужном месте сможешь применить правильный способ и избежать глупых ошибок
(rescue - "работает не всегда", а вот catch - всегда)

а если разработчик об этом не знает - то будут и ошибки и удивление почему
try-rescue не перехатывает ошибку :exit приходящую из таймаута GenServer

"Потроха Эрланга Вылезают из-под капота Эликсира"(c)автор курса




## 08.03 Пользовательские типы исключений

Это прло создание своих собственных исключений, поверх встроенных в Эликсир.
Создавать свои пользовательские исключения обычно нужно тем, кто привык строить
бизнес-логику и ControlFlow (управление потоком управления) на исключениях.
Но в Эликсир/Эрланг вообще не рекомендуется использовать исключения для
ControlFlow. Но Эликрсир даёт гибкость для тех кто привык так делать, но опять
таки для этого нужно использовать свои кастомные типы исключения а не встроенные
системные исключения.

Практический пример использования исключений.
У нас есть некий сервис с http API. принимающий запросы и отдающий ответы.
по ходу обработки входящих запросов производятся несколько основных действий:

- аутентификация
- авторизация (проверка прав)
- валидация данных

и каждое из этих действий(шагов) может прервать дальнейшее выполнение
например просто потому, что запрос пользователя не прошел аутентификацию или
валидацию входных данных. И вот для остановки каждого из этих шагов могут быть
использованы свои кастомные исключения.

> Создание исключения о том, что Аутентификация провалена

для описания своего кастомного исключения нужно исп-ть макрос defexception
```elixir
defmodule CustomExceptionDemo do

  defmodule Model do
    defmodule AuthentificationError do
      @enforce_keys [:type]
      defexception [:type, :token, :login]   # на подобии defstruct
      # ...
    end
  end
end
```

каждое исключение должно реализовывать behaviour Exception.
т.е. нужна строка кода `@behaviour Exception`, но её подставляет макрос
defexception, поэтому указывать это самому руками не нужно. Но нужно задать
функции коллбеки для Exception: expression и message:

```elixir
defmodule CustomExceptionDemo do

  defmodule Model do

    defmodule AuthentificationError do # наше кастомное исключение
      # @behaviour Exception  всякое исключение должно реализовывать Exception

      @enforce_keys [:type]
      defexception [:type, :token, :login]

      @impl true
      def exception({type, data}) do  # для создания экземпляра исключения
        case type do
          :token -> %__MODULE__{type: :token, token: data}
          :login -> %__MODULE__{type: :token, login: data}
          #          ^ AuthentificationError
        end
      end

      @impl true
      def message(exception) do  # для возврата текстового представления
        case exception.type do
          :token -> "AuthentificationError: invalid token"
          :login -> "AuthentificationError: invalid login"
        end
      end
    end
  end

end
```

проверяем написанное через iex-консоль
```sh
iex custom_exception_demo.exs
```

```elixir
iex> alias CustomExceptionDemo, as: C
iex> alias CustomExceptionDemo.Model, as: M
CustomExceptionDemo.Model

# кидаем исключение своего кастомного типа через raise
iex> raise(M.AuthentificationError, {:token, "aaaa"})
#          ^arg1                    ^arg2
** (CustomExceptionDemo.Model.AuthentificationError) AuthentificationError: invalid token
    iex:4: (file)
```

- arg2- вторым параметром идут данные по которым будет создан экземпляр
  нашего кастомного исключения

как это работает
- когда вызываем raise под копотом вызывается коллбек Exception.exception
  и создаёт экземпляр исключения
- "AuthentificationError: invalid token" - это то самое текстовое сообщение
  которое мы задали в своей реализации коллбека Exception.message

можно вызывать raise И без скобок, типо это такой синтаксис а не функция
как в java `throw new ...`
```elixir
iex> raise M.AuthentificationError, {:token, "aaaa"}
** (CustomExceptionDemo.Model.AuthentificationError) AuthentificationError: invalid token
    iex:4: (file)
```


#### исключение для аторизации (AuthZ)
аутентификация пройдена, теперь нужно проверить прова аутентифицированного юзера

```elixir
defmodule CustomExceptionDemo do

  defmodule Model do
    defmodule AuthentificationError do # who are you
      # ....
    end

    defmodule AuthorizationError do    # +++  what you can access
      defexception [:role, :action]
    end
  end

end
```

- role - роль юзера (админ, гость и т.д)
- action - действие которое он собирался сделать.

```elixir
    defmodule AuthorizationError do
      @enforce_keys [:role, :action]  # вообще для исключений это не обязательно
      defexception [:role, :action]

      @impl true
      def exception({role, action}) do
        %__MODULE__{role: role, action: action}
      end

      @impl true
      def message(exception) do
        "AuthentificationError: role #{exception.role} is not allowed to do"
          <> " action #{exception.action}"
      end
    end
  end
```

```elixir
r M
{:reloaded,
 [CustomExceptionDemo, CustomExceptionDemo.Model,
  CustomExceptionDemo.Model.AuthentificationError,
  CustomExceptionDemo.Model.AuthorizationError]}

# второй способ перкомпилировать весь модуль
iex> File.ls     # смотрю какие есть файлы в текущем каталоге
{:ok, ["custom_exception_demo.exs", "exception_demo.exs", "README.md"]}

# compile модуль
iex> c "custom_exception_demo.exs"
[CustomExceptionDemo, CustomExceptionDemo.Model,
 CustomExceptionDemo.Model.AuthentificationError,
 CustomExceptionDemo.Model.AuthorizationError]
```


```elixir
iex> raise M.AuthorizationError, {:guest, :reconfigure}
** (CustomExceptionDemo.Model.AuthorizationError) AuthentificationError: role guest is not allowed to do action reconfigure
    iex:7: (file)
```



```elixir
    defmodule SchemeValidationError do
      defexception [:schema_name]

      @impl true
      def exception(schema_name) do
        %__MODULE__{schema_name: schema_name}
      end

      @impl true
      def message(exception) do
        "SchemeValidationError: data does not match schema #{exception.schema_name}"
      end
    end
```

```elixir
iex> raise M.SchemeValidationError, "some_schema_json"
** (CustomExceptionDemo.Model.SchemeValidationError) SchemeValidationError: data does not match schema some_schema_json
    iex:8: (file)
```

Пишем пример в котором будем использовать свои исключения.

Напишем функцию handle - которая в нашем примере будет эмулировать ендпоинт
контроллера, принимающего http-запрос от клиента на стороне сервера.
схематично
```elixir
  def handle(request) do
    try do
      # шаг 1
      # шаг 2
      # шаг N
      # ответ клиенту при успехе
    rescue
      # перехват исключений и ответ клиенту об ошибке
    end
  end
```

```elixir
defmodule CustomExceptionDemo do

  defmodule Controller do
    # для возможности доступа к ислючениям в ф-и handle()
    alias CustomExceptionDemo.Model, as: M

    # as function of our service
    def handle(request) do # представляем что это обработчик внутри контроллера
      try do
        authenticate(request)
        authorize(request)
        validate(request)
        result = do_something_useful(request) # получение результата - "ответа"
        {200, result}
      rescue                                    # если что-то пошло не так
        error in [M.AuthentificationError, M.AuthorizationError] ->
          {403, Exception.message(error)} # сообщение об ошибке отправляем клиенту

        error in [M.SchemeValidationError] ->
          {409, Exception.message(error)}

        error ->
          IO.puts(Exception.format(:error, error, __STACKTRACE__))  # to log
          {500, "Internal Server Error"}                            # to client
      end
    end
  end

  defmodule Model do
    defmodule AuthentificationError do ... end
    defmodule AuthorizationError do ... end
    defmodule SchemeValidationError do ... end
  end
end
```



200 - это 200й код http-ответа (OK)
403 - стандартный http-код не авторизован или не хватает прав
500 - случилось что-то не предусмотренное в коде, добавляем логирование в stdout
`__STACKTRACE__` - это макрос который подставит стектрейс в лог


пишем заглушки шагов для проверки своих исключений

```elixir
    def authentificate(request) do
      case request.token do
        "aaa" -> :ok
        "bbb" -> :ok
        _ -> raise M.AuthentificationError, {:token, request.token}
      end
    end

    def authorize(request) do
      case request.token do
        "aaa" -> :ok
        _ -> raise M.AuthorizationError, {:guest, :reconfigure} # role + action
      end
    end

    def validate(request) do
      if Map.has_key?(request, data) do
        :ok
      else
        raise M.SchemeValidationError, "some_schema.json"
      end
    end
```

```elixir
defmodule CustomExceptionDemo do

  # request sample for happy path
  def request_1 do
    %{token: "aaa", data: %{a: 42}}
  end
  # .. остальные сэмплы будем писать сюда

  defmodule Controller do
    # ...
  end
end
```


```elixir
iex> c "custom_exception_demo.exs"
...
[CustomExceptionDemo, CustomExceptionDemo.Controller, CustomExceptionDemo.Model,
 CustomExceptionDemo.Model.AuthentificationError,
 CustomExceptionDemo.Model.AuthorizationError,
 CustomExceptionDemo.Model.SchemeValidationError]

iex> alias CustomExceptionDemo, as: C
CustomExceptionDemo

iex> C.request_1()
%{data: %{a: 42}, token: "aaa"}

# проверяем happy path доставая обьект запроса из ф-и генерящий sample
iex> C.request_1() |> C.Controller.handle()
{200, 42}

#
iex> %{data: %{a: 500}, token: "aaa"} |> C.Controller.handle()
{200, 500

iex> %{data: %{a: "Hi"}, token: "aaa"} |> C.Controller.handle()
{200, "Hi"}
```

дописываем остальные функции для получения других исключений
```elixir
  # request sample for happy path
  def request_1, do: %{token: "aaa", data: %{a: 42}}

  # request sample for AuthorizationError
  def request_2, do: %{token: "ccc", data: %{a: 42}}

  # request sample for AuthentificationError
  def request_3, do: %{token: "bbb", data: %{a: 42}}

  # request sample for SchemeValidationError
  def request_4, do: %{token: "aaa"}

  # request sample for Internal Server Error
  def request_5, do: %{token: "aaa", data: %{a: 100}}
```


```elixir
iex> C.request_2() |> C.Controller.handle()
{403, "AuthentificationError: invalid token"}

iex> C.request_3() |> C.Controller.handle()
{403, "AuthorizationError: role guest is not allowed to do action reconfigure"}

iex> C.request_4() |> C.Controller.handle()
{409, "SchemeValidationError: data does not match schema some_schema.json"}

iex> C.request_5() |> C.Controller.handle()
** (RuntimeError) somethign happend
    custom_exception_demo.exs:66: CustomExceptionDemo.Controller.do_something_useful/1
    custom_exception_demo.exs:28: CustomExceptionDemo.Controller.handle/1
    (elixir 1.18.3) src/elixir.erl:386: :elixir.eval_external_handler/3
    (stdlib 5.2) erl_eval.erl:750: :erl_eval.do_apply/7
    (elixir 1.18.3) src/elixir.erl:364: :elixir.eval_forms/4
    (elixir 1.18.3) lib/module/parallel_checker.ex:120: Module.ParallelChecker.verify/1
    (iex 1.18.3) lib/iex/evaluator.ex:336: IEx.Evaluator.eval_and_inspect/3
    (iex 1.18.3) lib/iex/evaluator.ex:310: IEx.Evaluator.eval_and_inspect_parsed/3

{500, "Internal Server Error"}
```


#### Summary - о подходе управления ControlFlow на кастомных исключениях

Выше приведённый код из custom_exception_demo.exs это типичный пример кода
который могуть писать разработчики пришедшие в ФП и в Эликсир в частности из
других языков, где для управления ControlFlow принято использовать исключения
(Java, Python) Эликсир даём возможность тем что привык к такому стилю писать
подобный код, хотя делать так не рекомендуется. В эликсире есть более удобный
способ делать ControlFlow вообще без исключений. (Это тема 9го урока)



