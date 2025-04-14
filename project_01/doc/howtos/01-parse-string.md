Elixir how to parse String "10h" to get number and char?


2025-04-13 15:20:47 assistant Blackbox deepseek-r1:

# think
Okay, the user wants to parse a string like "10h" into the number 10 and the
character 'h' using Elixir. Let me think about how to approach this.

First, I remember that Elixir has good string manipulation functions. Maybe
using String.split/2 or String.split/3 with a regular expression to separate
the numeric part from the letter. But wait, the string could have numbers
followed by letters, like "123abc". So splitting on the transition between
digits and non-digits might work.

Alternatively, using regular expressions to capture the number and the rest of
the string. A regex like ~r/^(\d+)(\D+)$/ could match the digits at the
beginning and the non-digits after. Then extract the two parts.

Once the parts are captured, converting the first part to an integer using
String.to_integer/1. The second part would be the characters, maybe stripped of
any whitespace if needed.

Another approach could be to iterate through the string, take the leading
characters that are digits, then the rest. But regex seems more efficient.

Wait, what if the string starts with non-digits? Like "h10"? Then the regex
might not capture correctly. But the user's example is "10h", so maybe assuming
the number comes first. The user might need to handle cases where there's no
number or no letters. But the question seems specific to "10h", so perhaps the
regex approach is sufficient.

So, the steps would be:

1. Use a regex to capture the numeric and alphabetic parts.
2. Convert the numeric part to an integer.
3. Return both parts.

Testing with "10h", the regex should capture "10" and "h". Then convert "10" to
10. For edge cases like "h10", the regex would not match, so maybe returning an
error or handling it. But the user's example is straightforward.

Implementing in Elixir:

string = "10h"
case String.split(string, ~r/(?<=\d)(?=\D)/) do
  [num, rest] -> {String.to_integer(num), rest}
  _ -> :error
end

Wait, the split with lookbehind and lookahead for digit followed by non-digit.
That split would split between the last digit and first non-digit. So "10h"
becomes ["10", "h"]. Then convert the first part to integer. That could work.

Alternatively, using String.split/2 with a regex that matches the boundary
between digits and non-digits. The split would result in two parts.

Another way is using Regex.run/3 with ~r/^(\d+)(.*)$/, then take the captures.
For "10h", captures would be ["10", "h"]. Then process them.

So:

string = "10h"
regex = ~r/^(\d+)(\D*)$/
case Regex.run(regex, string) do
  [_, num_str, char_str] -> {String.to_integer(num_str), char_str}
  _ -> :error
end

This regex ensures that the string starts with digits, followed by non-digits.
The \D* matches any non-digit characters after. But if there are digits after,
it won't capture. But the user's example is "h" which is non-digit. So this
should work.

But what if the string is "10h30m"? Then the regex would capture "10" and
"h30m". But maybe the user wants to split at the first non-digit. Hmm. The
original question is about "10h", so maybe the regex is sufficient.

So, the answer would involve using a regex to capture the leading digits and
the remaining characters, then converting the digits to an integer.

Another possible approach is using String.graphemes/1 to iterate through each
character, take the leading digits, then the rest. For example:

string = "10h"
{graphemes, rest} = Enum.split_while(String.graphemes(string), fn c -> c =~
~r/\d/ })
num = graphemes |> Enum.join() |> String.to_integer()
char = rest |> Enum.join()
{num, char}

This splits the string into graphemes, takes the leading digits, joins them
back to a string, converts to integer, then the rest is the characters. This
works even if there are digits later, but captures all leading digits. For
"10h30m", it would get 10 and "h30m". If the user wants to split at the first
non-digit, this works. If they need to split into all possible parts, that's
different. But the question is about "10h", so this method is valid.

So, possible solutions are either regex-based or using Enum.split_while. The
regex approach is more concise, but the Enum method is more flexible if the
logic needs to be adjusted.

In the answer, I should present both methods. Let me check the Elixir docs to
make sure the functions are correct.

String.split/3 with a regex that splits on the digit-non-digit boundary. The
regex (?<=\d)(?=\D) uses positive lookbehind for a digit and positive lookahead
for a non-digit, so it splits between them. Then splitting the string into two
parts. For "10h", it would split into ["10", "h"]. Then converting the first
part to integer.

Yes, that works. So:

num_str = "10h" |> String.split(~r/(?<=\d)(?=\D)/) |> hd()
char_str = "10h" |> String.split(~r/(?<=\d)(?=\D)/) |> tl() |> hd()
But if the string doesn't have such a split, like "10", then tl would be empty.
So using a case statement.

Alternatively:

case String.split("10h", ~r/(?<=\d)(?=\D)/) do
  [num, char] -> {String.to_integer(num), char}
  [num] -> {String.to_integer(num), ""}
  _ -> :error
end

But for the user's case, the first case would work.

So, summarizing, the answer can use either regex capture with Regex.run or
split the string. Both methods are valid. The regex approach might be more
straightforward.

So, the final answer would present both methods, perhaps, but the regex method
is more concise. Let me write the code examples.

</think>

# Answer:

To parse a string like `"10h"` into a number and character in Elixir, you can
use **regular expressions** or **pattern matching** to separate the numeric and
non-numeric parts. Here are two approaches:

---

### 1. Using Regular Expressions (Regex)
Split the string into numeric and non-numeric parts with a regex pattern:

```elixir
string = "10h"

# Split the string into parts using regex
case String.split(string, ~r/(?<=\d)(?=\D)/) do
  [num_str, char_str] ->
    {String.to_integer(num_str), char_str}
  _ ->
    {:error, "Invalid format"}
end

# Output: {10, "h"}
```

**Explanation:**
- `~r/(?<=\d)(?=\D)/` splits the string at the boundary between a digit (`\d`)
and a non-digit (`\D`).
- `String.to_integer/1` converts the numeric part to an integer.

---

### 2. Using Regex Captures
Extract the numeric and non-numeric parts using regex captures:

```elixir
string = "10h"

# Match the pattern and capture parts
case Regex.run(~r/^(\d+)(\D*)$/, string) do
  [_, num_str, char_str] ->
    {String.to_integer(num_str), char_str}
  _ ->
    {:error, "Invalid format"}
end

# Output: {10, "h"}
```

**Explanation:**
- `^(\d+)(\D*)$` matches strings starting with digits (`\d+`) followed by non-digits (`\D*`).
- The captured groups are converted to the desired format.

---

### 3. Using Enum and Pattern Matching (No Regex)
For more control, iterate through characters:

```elixir
string = "10h"

# Split into leading digits and remaining characters
{num_list, char_list} =
  string
  |> String.graphemes()
  |> Enum.split_while(&(&1 =~ ~r/\d/))

num = num_list |> Enum.join() |> String.to_integer()
chars = char_list |> Enum.join()

{num, chars}

# Output: {10, "h"}
```

**Explanation:**
- `Enum.split_while/2` splits the string into leading digits and the rest.
- `String.to_integer/1` converts the numeric part.

---

### Edge Cases
- If the string has **no numbers** (e.g., `"h"`), the regex methods will return
an error.
- If the string has **no letters** (e.g., `"10"`), the result will be `{10, ""}`.

Choose the method that best fits your use case!




