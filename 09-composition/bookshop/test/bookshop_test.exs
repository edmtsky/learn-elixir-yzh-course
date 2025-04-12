defmodule BookshopTest do
  use ExUnit.Case
  # require TestData

  test "data" do
    assert Bookshop.test_data() == TestData.valid_data()
  end
end
