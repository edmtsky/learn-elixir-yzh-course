defmodule Bookshop.Controller do
  alias Bookshop.Model, as: M

  def handle(request) do
    Bookshop.Solution1.handle(request)
  end

  @spec validate_incomming_data(map()) :: {:ok, map()} | {:error, :invalid_incomming_data}
  def validate_incomming_data(data) do
    if rand_success() do
      {:ok, data}
    else
      {:error, :invalid_incomming_data}
    end
  end

  @spec validate_user(name :: String.t()) :: {:ok, User.t()} | {:error, :user_not_found}
  def validate_user(name) do
    if rand_success() do
      {:ok, %M.User{id: name, name: name}}
    else
      {:error, :user_not_found}
    end
  end

  @spec validate_address(String.t()) :: {:ok, Address.t()} | {:error, :invalid_address}
  def validate_address(data) do
    if rand_success() do
      {:ok, %M.Address{other: data}}
    else
      {:error, :invalid_address}
    end
  end

  @spec validate_book(map()) :: {:ok, Book.t()} | {:error, :book_not_found}
  def validate_book(data) do
    if rand_success() do
      {:ok, %M.Book{title: data["title"], author: data["author"]}}
    else
      {:error, :book_not_found}
    end
  end

  def rand_success() do
    Enum.random(1..10) > 1
  end

end
