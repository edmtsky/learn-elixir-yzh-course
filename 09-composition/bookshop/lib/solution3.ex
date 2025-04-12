defmodule Bookshop.Solution3 do
  alias Bookshop.Model, as: M
  alias Bookshop.Controller, as: C
  alias Bookshop.Errors, as: E

  require Logger

  @spec handle(map()) :: {:ok, M.Order.t()} | {:error, any()}
  def handle(data) do
    try do
      data = C.validate_incoming_data!(data)

      %{
        "user" => username,
        "address" => address_str,
        "books" => books_data
      } = data

      cat = C.validate_user!(username)
      address = C.validate_address!(address_str)

      books =
        Enum.map(books_data, fn one_book_data ->
          C.validate_book!(one_book_data)
        end)

      order = M.Order.create(cat, address, books)
      {:ok, order}
    rescue
      e in [E.InvalidIncomingData, E.UserNotFound, E.InvalidAddress, E.BookNotFound] ->
        Logger.error(Exception.message(e))
        {:error, E.description(e)}
    end
  end
end
