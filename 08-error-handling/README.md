## Урок 8 Обработка ошибок

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


