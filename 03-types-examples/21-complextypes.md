## IO List

могут состоять из следующих частей
- byte 0..255
- strings
- IO-List

```elixir
iex(1)> [0] |> IO.iodata_to_binary
<<0>>

# 256
iex(2)> [0, 127, 255, 256] |> IO.iodata_to_binary
** (ArgumentError) errors were found at the given arguments:

  * 1st argument: not an iodata term

    :erlang.iolist_to_binary([0, 127, 255, 256])
    iex:2: (file)

iex(2)> [97, 98, 99] |> IO.iodata_to_binary
"abc"

iex(5)> [97,98,99,[100, 101]," Hello",[" "], "word", 33] |> IO.iodata_to_binary
"abcde Hello word!"
```

IO.List - сделан для оптимизации, чтобы постоянно не скеивать строки
может быть любой гулбины вложенности.

```elixir
iex(6)> name = "world"
# "world"
iex(7)> title = ["Hello", name, "!"]
# ["Hello", "world", "!"]
iex(8)> page = ["<h1>", title, "</h1>"]
# ["<h1>", ["Hello", "world", "!"], "</h1>"]
iex(9)> header = "<html><body>"
# "<html><body>"
iex(10)> footer = "</body></html>"
# "</body></html>"
iex(11)> html = [header, page, footer]
# ["<html><body>", ["<h1>", ["Hello", "world", "!"], "</h1>"], "</body></html>"]
iex(12)> IO.iodata_to_binary(html)
# "<html><body><h1>Helloworld!</h1></body></html>"
iex(13)> IO.puts(html)
# <html><body><h1>Helloworld!</h1></body></html>
# :ok


```

KeyWordList предшественник Map
фактически это простой список состоящий из кортежев из 2х эл-тов каждый.
но при этом имеет синтаксический сахар и поддержку для работы как будто с
мапой. при условии что первые элементы всех кортежей внутри списка - это атомы
(ключ)

```elixir
iex(2)> my_dict = [{:a, 42}, {:b, 100}, {:c, 500}]
[a: 42, b: 100, c: 500]

iex(3)> my_dict[:a]     # => 42
iex(4)> my_dict[:b]     # => 100
iex(5)> my_dict[:c]     # => 500
iex(6)> my_dict[:d]     # => nil

# Если хотябы один из ключей не является атомом то такой список не будет
# считаться KeywordList-ом:

iex(7)> my_dict2 = [{:a, 42}, {:b, 100}, {"c", 500}]
[{:a, 42}, {:b, 100}, {"c", 500}]
```

Обрати внимание что при создании списка где все перве эл-ты кортежей атомы
то и вывод у него похож не на список кортежей а скорее на мапу.(my_dict)

Во втором случае только один ключ - строка и вся структура уже не распознаётся
как KeywordList

iex(8)> Keyword.get(my_dict, :b)
100

Map.fetch -> Keyword.fetch

```elixir
iex(9)> Keyword.fetch(my_dict, :a)
{:ok, 42}
iex(10)> Keyword.fetch(my_dict, :d)
:error

iex(11)> Keyword.get(my_dict, :a)
42
iex(12)> Keyword.get(my_dict, :d)
nil
```

добавлять можно так же как элементы в обычный список
```elixir
iex(14)> my_dict = [{:a, 42}, {:b, 100}, {:c, 500}]
[a: 42, b: 100, c: 500]

iex(15)> my_dict = [{:d, 100} | my_dict]
[d: 100, a: 42, b: 100, c: 500]

iex(16)> my_dict[:d]
100
```

KeywordList наследие времён когда в языке еще вообще не было поддержки Map.
Вроде как бы можно было бы их больше и не использовать, но это уже традиция
случаи где используются KeyworList:

1. функции принимающие последним параметром некий список опций(настроек)
  `h String.split`

def split(string, pattern, options \\ [])

```elixir
iex(18)> String.split("a b c", " ")
["a", "b", "c"]

iex(19)> String.split("a b c", " ", parts: 2) # => [parts: 2]
["a", "b c"]

iex(21)> String.split("a  b  c", " ")
["a", "", "b", "", "c"]

iex(22)> String.split("a  b  c", " ", trim: true)
["a", "b", "c"]

iex(23)> String.split("a  b  c", " ", trim: true, parts: 2)
["a", " b  c"]

# раскрываем синтаксический сахар до полного синтаксиса
iex(24)> String.split("a  b  c", " ", [trim: true, parts: 2])
["a", " b  c"]
iex(25)> String.split("a  b  c", " ", [{:trim, true}, {:parts, 2}])
["a", " b  c"]

iex(26)> String.replace("Hello world!", "o", "O")
"HellO wOrld!"

# только первое вхождение
iex(27)> String.replace("Hello world!", "o", "O", global: false)
"HellO world!"
```
