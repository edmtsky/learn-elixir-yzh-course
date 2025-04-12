defmodule Bookshop.Solution5 do
  alias Bookshop.Model, as: M
  alias Bookshop.Solution4, as: S4

  @spec handle(map()) :: {:ok, M.Order.t()} | {:error, any()}
  def handle(data) do
    FP.pipeline(data, [
      &S4.step_validate_incoming_data/1,
      &S4.step_validate_user/1,
      &S4.step_validate_address/1,
      &S4.step_validate_books/1,
      &S4.step_create_order/1
    ])
  end
end
