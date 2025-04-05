#!/bin/sh

echo TEST caesar_test
# elixirc caesar.ex && elixir caesar_test.exs
elixir caesar.ex caesar_test.exs

echo TEST trim
# elixirc trim.ex && elixir trim_test.exs
elixir trim.ex trim_test.exs

echo TEST my_list
# elixirc my_list.ex && elixir my_list_test.exs
elixir my_list.ex my_list_test.exs
