defmodule Bookshop.Controller do
  alias Bookshop.Model, as: M

  # Emulation of the check in the database
  @existing_users ["Joe", "Alice", "Bob" ]
  @existing_authors ["Scott Wlaschin", "Mikito Takada", "Marx, Valim, Tate" ]

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

  # def rand_success() do
  #   Enum.random(1..10) > 1
  # end

end
