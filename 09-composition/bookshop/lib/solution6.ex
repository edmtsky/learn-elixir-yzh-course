defmodule Bookshop.Solution6 do
  alias Bookshop.Model, as: M
  alias Bookshop.Controller, as: C

  @spec handle(map()) :: {:ok, M.Order.t()} | {:error, any()}
  def handle(data) do
    with {:ok, data} <- C.validate_incoming_data(data),
         %{"user" => uname, "address" => addr_s, "books" => books_data } = data,
         {:ok, user} <- C.validate_user(uname),
         {:ok, address} <- C.validate_address(addr_s),
         books = Enum.map(books_data, fn ob_data -> C.validate_book(ob_data) end),
         {:ok, books} <- FP.sequence(books)
    do
      order = M.Order.create(user, address, books)
      {:ok, order}
    end
  end
end
