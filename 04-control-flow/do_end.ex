defmodule DoEnd do
  @moduledoc """

  """
  def my_fun(arg1, options) do
    dbg(arg1)
    dbg(options)
  end

  # play with if-macro

  def if_1a(condition) do
    if condition do
      a = 42
      {:branch_1, a}
    else
      b = 100
      {:branch_2, b + 10}
    end
  end

  def if_1b(condition) do
    if condition, do:
                    (
                      a = 42
                      {:branch_1, a}
                    ),
                  else: (
                    b = 100
                    {:branch_2, b + 10}
                  )
  end

  def if_1c(condition) do
    if condition, [do:
                    (
                      a = 42
                      {:branch_1, a}
                    ),
                  else: (
                    b = 100
                    {:branch_2, b + 10}
                  )]
  end

  def if_1d(condition) do
    branch_1 = (
      a = 42
      {:branch_1, a}
    )
    branch_2 = (
      b = 100
      {:branch_2, b + 10}
    )
    if condition, [do: branch_1, else: branch_2]
  end

  def if_1e(condition) do
    branch_1 = (
      a = 42
      {:branch_1, a}
    )
    branch_2 = (
      b = 100
      {:branch_2, b + 10}
    )
    if(condition, [do: branch_1, else: branch_2])
  end

  # def-macro

  def some_fun(arg1, arg2) do
    a = arg1 + arg2
    a + 42
  end

  def some_fun1(arg1, arg2), do: (
    a = arg1 + arg2
    a + 42
  )

  def some_fun2(arg1, arg2), do: (a = arg1 + arg2; a + 42)

  def some_fun3(arg1, arg2), [do: (a = arg1 + arg2; a + 42)]

  def(some_fun4(arg1, arg2), [do: (a = arg1 + arg2; a + 42)])

  #
  # defmodule-macro

  defmodule MyModule do
    def f1(), do: 42
    def f2(), do: 100
  end

  # defmodule MyModule1, do: (
  #   def f1(), do: 42
  #   def f2(), do: 100
  # )

  # defmodule MyModule1, do: ( def f1(), do: 42; def f2(), do: 100)

  # defmodule MyModule1, [do: ( def f1(), do: 42; def f2(), do: 100)]

  defmodule(MyModule1, [do: ( def f1(), do: 42; def f2(), do: 100)])

  # defmodule(MyModule2, [do: ( def f1(), do: 42; def f2(), do: 100), other: 42])
  # attemp to compile give:
  # ** (MatchError) no match of right hand side value:
  # {:error, [{"04-control-flow/do_end.ex", 107,
  #   "** (FunctionClauseError) no function clause matching in Kernel.defmodule/2
  #       (elixir 1.16.1) expanding macro: Kernel.defmodule/2
  #       do_end.ex:107: DoEnd (module)\n"}],
  # [{"04-control-flow/do_end.ex", 1,
  # "redefining module DoEnd (current version defined in memory)"}]}
  #  (iex 1.16.1) lib/iex/helpers.ex:440: IEx.Helpers.r/1
  #  iex:48: (file)


  # def(some_fun4(arg1, arg2), [do: (a = arg1 + arg2; a + 42), other: 42])
  # attemp to compile give:

# error: unexpected option :other in "try"
#      │
#  120 │   def(some_fun4(arg1, arg2), [do: (a = arg1 + arg2; a + 42), other: 42])
#      │       ^
#      │
#      └─ do_end.ex:120:7: DoEnd.some_fun4/2
#
#
# == Compilation error in file do_end.ex ==
# ** (CompileError) do_end.ex: cannot compile module DoEnd (errors have been logged)
#     (stdlib 5.2) lists.erl:1706: :lists.mapfoldl_1/3
#     (stdlib 5.2) lists.erl:1707: :lists.mapfoldl_1/3
# ** (MatchError) no match of right hand side value: {:error, [{"/d/Dev/2024/elixir/learning-yzh/04-control-flow/do_end.ex", {120, 7}, "unexpected option :other in \"try\""}, {"/d/Dev/2024/elixir/learning-yzh/04-control-flow/do_end.ex", 0, "** (CompileError) do_end.ex: cannot compile module DoEnd (errors have been logged)\n    (stdlib 5.2) lists.erl:1706: :lists.mapfoldl_1/3\n    (stdlib 5.2) lists.erl:1707: :lists.mapfoldl_1/3\n"}], [{"/d/Dev/2024/elixir/learning-yzh/04-control-flow/do_end.ex", 1, "redefining module DoEnd (current version defined in memory)"}, {"/d/Dev/2024/elixir/learning-yzh/04-control-flow/do_end.ex", 91, "redefining module DoEnd.MyModule (current version defined in memory)"}, {"/d/Dev/2024/elixir/learning-yzh/04-control-flow/do_end.ex", 105, "redefining module DoEnd.MyModule1 (current version defined in memory)"}]}
#     (iex 1.16.1) lib/iex/helpers.ex:440: IEx.Helpers.r/1
#     iex:48: (file)

  # full do-end block is a syntax sugar:
  # do
  #   line1
  #   line2
  #   line3
  # end

  # original shape is:
  # do: (line1; line2; line3)
  # key: value in keyword list
  # so
  # def my_fun(42, []), do: 42 ->
  #                   ^   ^ separator in key-value in keyword-list
  #                   ^ args separator
  # so the same :
  # def(my_fun(42, []), [do: 42])
  #     arg1,            arg2     where arg2 is a keyword-list
end
