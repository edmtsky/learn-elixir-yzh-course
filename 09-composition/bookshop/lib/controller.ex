defmodule Bookshop.Controller do
  alias Bookshop.Model, as: M
  alias Bookshop.Errors, as: E

  # Emulation of the check in the database
  @existing_users ["Joe", "Alice", "Bob"]
  @existing_authors ["Scott Wlaschin", "Mikito Takada", "Marx, Valim, Tate"]

  def handle(request) do
    Bookshop.Solution1.handle(request)
  end

  @spec validate_incoming_data(map()) :: {:ok, map()} | {:error, :invalid_incoming_data}
  def validate_incoming_data(%{"user" => _, "address" => _, "books" => _} = data) do
    {:ok, data}
  end

  def validate_incoming_data(_) do
    {:error, :invalid_incoming_data}
  end

  @spec validate_user(name :: String.t()) :: {:ok, User.t()} | {:error, :user_not_found}
  def validate_user(name) do
    if name in @existing_users do
      {:ok, %M.User{id: name, name: name}}
    else
      {:error, :user_not_found}
    end
  end

  @spec validate_address(String.t()) :: {:ok, Address.t()} | {:error, :invalid_address}
  def validate_address(data) do
    if String.length(data) > 5 do
      {:ok, %M.Address{other: data}}
    else
      {:error, :invalid_address}
    end
  end

  @spec validate_book(map()) :: {:ok, Book.t()} | {:error, :book_not_found}
  def validate_book(%{"author" => author} = data) do
    if author in @existing_authors do
      {:ok, %M.Book{title: data["title"], author: data["author"]}}
    else
      {:error, :book_not_found}
    end
  end

  # with exceptions

  @spec validate_incoming_data!(map()) :: map()
  def validate_incoming_data!(%{"user" => _, "address" => _, "books" => _} = data) do
    data
  end

  def validate_incoming_data!(_) do
    raise E.InvalidIncomingData
  end

  @spec validate_user!(name :: String.t()) :: User.t()
  def validate_user!(name) do
    if name in @existing_users do
      %M.User{id: name, name: name}
    else
      raise E.UserNotFound, name
    end
  end

  @spec validate_address!(String.t()) :: Address.t()
  def validate_address!(data) do
    if String.length(data) > 5 do
      %M.Address{other: data}
    else
      raise E.InvalidAddress, data
    end
  end

  @spec validate_book!(map()) :: Book.t()
  def validate_book!(%{"author" => author} = data) do
    if author in @existing_authors do
      %M.Book{title: data["title"], author: data["author"]}
    else
      raise E.BookNotFound, {data["title"], data["author"]}
    end
  end
end
