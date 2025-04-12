defmodule TestData do
  def valid_data() do
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

  def invalid_data() do
    %{
      "admin" => "Attis",
      "address" => "Freedom str 7/42 City Country"
    }
  end

  def valid_book do
    %{
      "title" => "Adopting Elixir",
      "author" => "Marx, Valim, Tate"
    }
  end

  def invalid_book do
    %{
      "title" => "Functional Web Development with Elixir, OTP and Phoenix",
      "author" => "Lance Halvorsen"
    }
  end
end
