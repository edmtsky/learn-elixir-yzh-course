defmodule Bookshop.Solution2 do
  alias Bookshop.Model, as: M
  alias Bookshop.Controller, as: C

  @spec handle(map()) :: {:ok, M.Order.t()} | {:error, any()}
  def handle(data) do
    case C.validate_incoming_data(data) do
      {:ok, data} ->
        state = %{}
        handle_user(data, state)

      {:error, error} ->
        {:error, error}
    end
  end

  def handle_user(data, state) do
    case C.validate_user(data["user"]) do
      {:ok, user} ->
        state = Map.put(state, :user, user)
        handle_address(data, state)

      {:error, error} ->
        {:error, error}
    end
  end

  def handle_address(data, state) do
    case C.validate_address(data["address"]) do
      {:ok, address} ->
        state = Map.put(state, :address, address)
        create_order(data, state)

      {:error, error} ->
        {:error, error}
    end
  end

  # handle_books + create_order
  def create_order(%{"books" => books}, state) do
    # data["books"]
    books
    |> Enum.map(&C.validate_book/1)
    |> Enum.reduce({[], nil}, fn
      {:ok, book}, {books, nil} -> {[book | books], nil}
      {:error, error}, {books, nil} -> {books, {:error, error}}
      _maybe_book, acc -> acc
    end)
    |> case do
      # {books, nil} -> {:ok, books}
      # +
      {books, nil} -> {:ok, M.Order.create(state.user, state.address, books)}
      {_, error} -> error
    end
  end
end
