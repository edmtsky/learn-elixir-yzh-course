# Example of solving the fizzbuzz task
[FizzBuzz](https://ru.wikipedia.org/wiki/Fizz_buzz):


## What we learn about

Solving this task, we get acquainted with such elements of the elixir-lang as:
- modules and functions;
- generating a list using `Range`;
- iteration through the list using `Enum.each`;
- conditional jumps using `cond do`;
- guards expressions (guards);
- output to the console;
- pipe operator;
- and unit tests.


Here are iterations of the source code that changes as the task is implemented
the `fizzbuzz.exs` file is the final solution to this problem.

## Run the tests (final solution with tests in same source file)
```sh
elixir ./fizzbuzz.exs
```

## final solution (src and tests in separate files)

### Notes about Testing:

If you connected the test framework incorrectly,
```elixir
ExUnit.start()

defmodule FizzBuzzTest do
  use ExUnit                          # << the correct way is "use ExUnit.Case"
  import FizzBuzz
  ...
```
it will give the following error:
```sh
elixir fizzbuzz.exs
** (CompileError) fizzbuzz.exs:34: undefined function test/2
```

Correct: `ExUnit.Case`


```sh
elixir fizzbuzz.exs
.

Finished in 0.04 seconds (0.04s on load, 0.00s on tests)
1 test, 0 failures
```

