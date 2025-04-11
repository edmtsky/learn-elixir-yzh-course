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


