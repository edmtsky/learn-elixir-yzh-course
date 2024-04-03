## Управление потоком выполнения.

### Конструкция case и тела функций(function clauses) (v24)

lib/control_flow_i1.ex

> control flow with case

```elixir
iex(1)> r ControlFlow
{:reloaded, [ControlFlow]}
iex(2)> alias ControlFlow, as: CF
ControlFlow
iex(3)>  CF.handle2({:mouse, "Jerry"}, :pet)
pet the mouse Jerry
:ok
iex(4)> CF.handle2({:mouse, "Jerry"}, :feed)
feed the mouse Jerry
:ok
iex(8)> CF.handle2({:cat, "Tom"}, :pet)
pet the cat Tom
:ok
iex(9)> CF.handle2({:dog, "Spike"}, :pet)
pet the dog Spike
:ok

iex(10)> CF.handle2({:dog, "Spike"}, :scratch)
** (CaseClauseError) no case clause matching: {{:dog, "Spike"}, :scratch}
    control_flow.ex:30: ControlFlow.handle2/2
    iex:10: (file)
```

> handle3 function clauses
```elixir
iex(11)> r ControlFlow
{:reloaded, [ControlFlow]}

iex(12)> CF.handle3({:dog, "Spike"}, :pet)
pet the dog Spike
:ok
```


> когда ни один из описанных шаблонов в телах функций не подходит

```elixir
iex(13)> CF.handle3({:shark, "Spike"}, :feed)
** (FunctionClauseError) no function clause matching in ControlFlow.handle3/2

    The following arguments were given to ControlFlow.handle3/2:

        # 1
        {:shark, "Spike"}

        # 2
        :feed

    control_flow.ex:43: ControlFlow.handle3/2
    iex:13: (file)
iex(13)>

```

Добавив обобщённый шаблон для любого животного и действия.
```elixir
iex(13)> r ControlFlow
{:reloaded, [ControlFlow]}

iex(14)> CF.handle3({:shark, "Spike"}, :feed)
do action 'feed' with animal '{:shark, "Spike"}'
:ok
```

## How to run Test

```sh
elixir -r test_helper.exs -r 04-control-flow/control_flow_i1.ex \
                             04-control-flow/control_flow_test.exs
```


## Guards


```elixir
iex> r CF
{:reloaded, [ControlFlowI2]}

iex> library1 = {:library, 5, ["book1", "book2", "book3"]}
iex> library2 = {:library, 5, ["book1"]}
iex> library3 = {:library, 3, ["book1", "book2", "book3"]}
iex> library4 = {:library, 3, ["book1"]}

iex> CF.handle6(library1)
a good library
:ok
iex> CF.handle6(library2)
no so good library
:ok
iex> CF.handle6(library3)
no so good library
:ok
iex> CF.handle6(library4)
not recomended
:ok
```


В Guards можно использовать ограниченый набор функций(См документацию)

Вот пример того что будет если попытаться использовать в гарде свою ф-ю


  ```elixir
defmodule ControlFlow do
  # ...
  def handle6({:library, _rating, _books}) do
    IO.puts("not recomended")
  end

 def handle7(a) when handle6(a) == :ok do
end
```

```
iex(21)> r CF
    warning: redefining module ControlFlowI2 (current version defined in memory)
    │
  2 │ defmodule ControlFlowI2 do
    │ ~~~~~~~~~~~~~~~~~~~~~~~~~~
    │
    └─ control_flow_i2.ex:2: ControlFlowI2 (module)

    error: cannot find or invoke local handle6/1 inside guards. Only macros can be invoked in a guards and they must be defined before their invocation. Called as: handle6(a)
    │
 68 │   def handle7(a) when handle6(a) == :ok do
    │                       ^
    │
    └─ control_flow_i2.ex:68:23: ControlFlowI2.handle7/1


== Compilation error in file control_flow_i2.ex ==
** (CompileError) control_flow_i2.ex: cannot compile module ControlFlowI2 (errors have been logged)

** (MatchError) no match of right hand side value: {:error, [{"/d/Dev/2024/elixir/learning-yzh/04-control-flow/control_flow_i2.ex", {68, 23}, "cannot find or invoke local handle6/1 inside guards. Only macros can be invoked in a guards and they must be defined before their invocation. Called as: handle6(a)"}, {"/d/Dev/2024/elixir/learning-yzh/04-control-flow/control_flow_i2.ex", 0, "** (CompileError) control_flow_i2.ex: cannot compile module ControlFlowI2 (errors have been logged)\n\n"}], [{"/d/Dev/2024/elixir/learning-yzh/04-control-flow/control_flow_i2.ex", 2, "redefining module ControlFlowI2 (current version defined in memory)"}]}
    (iex 1.16.1) lib/iex/helpers.ex:440: IEx.Helpers.r/1
    iex:21: (file)
```


### Использование макросов в Guard

```elixir
iex(23)> r CF
{:reloaded, [ControlFlowI2]}
iex(24)> CF.handle7(1)
1 is odd
:ok
iex(25)> CF.handle7(2)
2 is even
:ok
iex(26)>
```


## Как работают исключения внутри Guard - вычисление в false

Тоже самое в теле функции - создаст исключение
```elixir
  # ..
  # Errors in Guards

  def handle8(a, b) when 10 / a > 2 do  # no error - just give false
    {:clause_1, b}
  end

  def handle8(_a, b) do
    {:clause_2, 10 / b} # -- div by zero -- raise an error
  end
```

```elixir-iex
iex(31)> CF.handle8(10, 0)
iex(31)> CF.handle8(10, 0)
** (ArithmeticError) bad argument in arithmetic expression
    control_flow_i2.ex:85: ControlFlowI2.handle8/2
    iex:31: (file)
```


Т.к. в Guard-ах исключения не выбрасываются наружу а просто возвращают false
то такое поведение можно использовать для более короткого синтаксиса
вот пример где можно убрать макрос Kernel.is_map без измнений логики работы:

```elixir
 # def handle9(m) when is_map(m) and map_size(m) > 2 do
  def handle9(m) when map_size(m) > 2 do
    IO.puts("big map")
  end

  def handle9(m) do
    IO.puts("not a big map (or not a map)")
  end
```

```elixir
iex(42)> CF.handle9(42)
not a big map (or not a map)
:ok
iex(43)> CF.handle9(%{a: 1, b: 2, c: 3})
big map
:ok
```
