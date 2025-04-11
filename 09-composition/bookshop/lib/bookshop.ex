defmodule Bookshop do
  @moduledoc """
  """
  @doc """
  """
  def test_data() do
    %{
      "user" => "Attis",
      "address" => "Freedom str 7/42 City Country",
      "books" => [
        %{
          "title" => "Domain Modeling Made Functional",
          "author" => "Scott Wlaschin" },
        %{
          "title" => "Distributed systems for fun and profit",
          "author" => "Mikito Takada"},
        %{
          "title" => "Adopting Elixir",
          "author" => "Marx, Valim, Tate"
        },
      ]
    }
  end
end
