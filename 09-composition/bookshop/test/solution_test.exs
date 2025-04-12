defmodule Bookshop.SolutionTest do
  use ExUnit.Case
  alias Bookshop.Model, as: M
  # alias Bookshop.Solution1, as: S
  # alias Bookshop.Solution2, as: S
  alias Bookshop.Solution3, as: S

  test "create order" do
    valid_data = TestData.valid_data()

    assert S.handle(valid_data) ==
             {:ok,
              %M.Order{
                client: %M.User{id: "Joe", name: "Joe"},
                address: %M.Address{
                  state: nil,
                  city: nil,
                  other: "Freedom str 7/42 City State"
                },
                books: [
                  %M.Book{title: "Adopting Elixir", author: "Marx, Valim, Tate"},
                  %M.Book{
                    title: "Distributed systems for fun and profit",
                    author: "Mikito Takada"
                  },
                  %M.Book{title: "Domain Modeling Made Functional", author: "Scott Wlaschin"}
                ]
              }}
  end

  test "invalid incoming data" do
    valid_data = TestData.invalid_data()

    assert S.handle(valid_data) == {:error, :invalid_incoming_data}
  end

  test "invalid user" do
    data =
      TestData.valid_data()
      |> Map.put("user", "Nemean")

    assert S.handle(data) == {:error, :user_not_found}
  end

  test "invalid address" do
    data =
      TestData.valid_data()
      |> Map.put("address", "wrong")

    assert S.handle(data) == {:error, :invalid_address}
  end

  test "invalid book" do
    invalid_book = TestData.invalid_book()

    data =
      TestData.valid_data()
      |> update_in(["books"], fn books -> [invalid_book | books] end)

    assert S.handle(data) == {:error, :book_not_found}
  end
end
