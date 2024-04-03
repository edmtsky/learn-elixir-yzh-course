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

