# 10-04-2025 @author Swarg
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
    after
      IO.puts("after is always called")
    end
  end
end

