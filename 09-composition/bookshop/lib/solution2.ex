defmodule Bookshop.Solution2 do
  alias Bookshop.Model, as: M
  alias Bookshop.Controller, as: C

  @spec handle(map()) :: {:ok, M.Order.t()} | {:error, any()}
  def handle(data) do
    case C.validate_incoming_data(data) do
      {:ok, data} ->
        case C.validate_user(data["user"]) do
          {:ok, user} ->
            case C.validate_address(data["address"]) do
              {:ok, address} ->
                case handle_books(data["books"]) do
                  {:ok, books} -> {:ok, M.Order.create(user, address, books)}
                  error -> error
                end

              {:error, error} ->
                {:error, error}
            end

          {:error, error} ->
            {:error, error}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  def handle_books(books) do
    books # data["books"]
    |> Enum.map(&C.validate_book/1)
    |> Enum.reduce({[], nil}, fn
      {:ok, book}, {books, nil} -> {[book | books], nil}
      {:error, error}, {books, nil} -> {books, {:error, error}}
      _maybe_book, acc -> acc
    end)
    |> case do
      {books, nil} -> {:ok, books}
      {_, error} -> error
    end
  end
end
