defmodule Bookshop do
  @moduledoc """
  """
  @doc """
  """
  def test_data() do
    %{
      "user" => "Joe",
      "address" => "Freedom str 7/42 City State",
      "books" => [
        %{
          "title" => "Domain Modeling Made Functional",
          "author" => "Scott Wlaschin"
        },
        %{
          "title" => "Distributed systems for fun and profit",
          "author" => "Mikito Takada"
        },
        %{
          "title" => "Adopting Elixir",
          "author" => "Marx, Valim, Tate"
        }
      ]
    }
  end
end
