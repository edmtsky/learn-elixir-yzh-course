defmodule UrlParser do
  @moduledoc """
    Parse url to parts. happy path only, ignore wrong key-value in query-params
  """

  def test_url() do
    "https://elixir-lang.org/section/subsection/page.html?a=42&b=100&c=500"
  end

  @doc """
      iex> parse("https://elixir-lang.org/path/to/page?html?a=42&b=88")
      %{
         protocol: "https",
         domain: "elixir-lang.org",
         path: "section/subsection/page.html",
         params: %{"a" => "42", "b" => "88"}
      }
  """
  def parse(url) do
    [protocol, rest] = String.split(url, "://")
    # [domain | rest] = String.split(rest, "/") # case: list with sz > 2 use: |
    [domain, rest] = String.split(rest, "/", parts: 2)
    [path, rest] = String.split(rest, "?")

    %{
      protocol: protocol,
      domain: domain,
      path: path,
      params: parse_params(rest)
    }
  end

  def parse_params(str) do
    String.split(str, "&")
    |> do_parse_params(%{})
  end

  defp do_parse_params([], acc), do: acc

  defp do_parse_params([pair | rest_pairs], acc) do
    case String.split(pair, "=") do
      [key, value] ->
        updated_acc = Map.put(acc, key, value)
        do_parse_params(rest_pairs, updated_acc)

      _ ->
        # just ignore wrong pair
        do_parse_params(rest_pairs, acc)
    end
  end
end

ExUnit.start()

defmodule UrlParserTest do
  use ExUnit.Case
  import UrlParser
  # doctest UrlParser # ** (ExUnit.DocTest.Error) 19-urlparser.exs:
  # could not retrieve the documentation for module UrlParser.
  # The BEAM file of the module cannot be accessed

  test "parse_params" do
    assert %{} = parse_params("")
    assert %{"a" => "42"} == parse_params("a=42")

    assert %{"a" => "42", "b" => "100", "c" => "500", "d" => "hello"} ==
             parse_params("a=42&b=100&c=500&d=hello")
  end

  test "parse_params with invalid kv-pair" do
    assert %{"a" => "42", "c" => "500"} == parse_params("a=42&b100&c=500")
  end

  test "parse" do
    assert %{
             protocol: "https",
             domain: "elixir-lang.org",
             path: "section/subsection/page.html",
             params: %{"a" => "42", "b" => "100", "c" => "500"}
           } == parse(test_url())
  end
end

# iex(30)> String.split("", "&")
# [""]
