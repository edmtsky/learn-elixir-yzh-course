defmodule Bookshop.Errors do
  defmodule InvalidIncomingData do
    defexception []

    @impl true
    def exception(_), do: %InvalidIncomingData{}

    @impl true
    def message(_ex), do: "InvalidIncomingData"
  end

  defmodule UserNotFound do
    defexception [:name]

    @impl true
    def exception(name), do: %UserNotFound{name: name}

    @impl true
    def message(ex), do: "UserNotFound #{ex.name}"
  end

  defmodule InvalidAddress do
    defexception [:data]

    @impl true
    def exception(data), do: %InvalidAddress{data: data}

    @impl true
    def message(ex), do: "InvalidAddress #{ex.data}"
  end

  defmodule BookNotFound do
    defexception [:title, :author]

    @impl true
    def exception({title, author}), do: %BookNotFound{title: title, author: author}

    @impl true
    def message(ex), do: "BookNotFound #{ex.title} #{ex.author}"
  end

  def description(%InvalidIncomingData{}), do: :invalid_incoming_data
  def description(%InvalidAddress{}), do: :invalid_address
  def description(%UserNotFound{}), do: :user_not_found
  def description(%BookNotFound{}), do: :book_not_found
end
