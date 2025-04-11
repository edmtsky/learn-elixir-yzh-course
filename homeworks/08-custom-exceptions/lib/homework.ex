defmodule IndexOutOfBoundsError do
  @moduledoc """
  Exception **IndexOutOfBoundsError** must be implemented so that
  Its `message` corresponded to the format of `" index 42 is out of bounds [0-3) "`,
  его message соответствовал формату `"index 42 is out of bounds [0-3)"`,
  where Index and Bounds should correspond to the arguments of functions.
  See which Message is expected in tests in different cases.
  """
  defexception [:msg]

  @impl true
  def exception(msg) do
    %__MODULE__{msg: msg}
  end

  @impl true
  def message(exception) do
    # "IndexOutOfBoundsError: #{exception.msg}"
    "#{exception.msg}"
  end
end

defmodule Homework do
  @doc """
  The function get_from_list!/2  accepts the list and index.
  returns the element of the list by the index or
  generates the IndexOutOfBoundError expection if index is invalid.
  """
  @spec get_from_list!([any()], integer()) :: any()
  def get_from_list!(list, index) do
    case do_get_from_list(list, index, 0) do
      {:ok, elm} -> elm
      {:error, errmsg} -> raise(IndexOutOfBoundsError, errmsg)
    end
  end

  @doc """
  Function get_from_list/2 works the same as get_from_list!/2,
  but it returns the tuple `{:ok, result}` in a successful case or
  tuple `{:error, err_message}`, if index is invalid.
  """
  @spec get_from_list([any()], integer()) :: {:ok, any()} | {:error, String.t()}
  def get_from_list(list, index) do
    do_get_from_list(list, index, 0)
  end

  defp do_get_from_list([], index, curr_index) do
    {:error, "index #{index} is out of bounds [0-#{curr_index})"}
  end

  defp do_get_from_list([head | tail], index, curr_index) when index == curr_index do
    {:ok, head}
  end

  defp do_get_from_list([head | tail], index, curr_index) do
    do_get_from_list(tail, index, curr_index + 1)
  end

  #

  @doc """
  The Get_Many_from_List!/2 function accepts arguments:
  - a list of some elements and
  - a list of indices.
  It returns a new list of elements, respectively obtained indices.

  ## Example:

    iex> Homework.get_many_from_list!(["cat", "dog", "fish"], [0, 0, 2, 2])
    ["cat", "cat", "fish", "fish"]
  """
  @spec get_many_from_list!([any()], [integer()]) :: [any()]
  def get_many_from_list!(list, indices) do
    case do_get_many_from_list(list, indices, []) do
      {:ok, new_list} ->
        new_list

      {:error, msg} ->
        raise(IndexOutOfBoundsError, msg)
    end
  end

  @doc """
  Function ** get_Many_from_List/2 ** works the same way, but
  returns the tuple `{: ok, result}` in a successful case or
  tuple `{: error, err_message}`, if index is not valid.

  ## Example:

    iex> Homework.get_many_from_list(["cat", "dog", "fish"], [1, 0])
    {:ok, ["dog", "cat"]}

  """
  @spec get_many_from_list!([any()], [integer()]) :: {:ok, [any()]} | {:error, String.t()}
  def get_many_from_list(list, indices) do
    do_get_many_from_list(list, indices, [])
  end

  defp do_get_many_from_list(_list, [], output) do
    {:ok, Enum.reverse(output)}
  end

  defp do_get_many_from_list(list, [index | rest_indices], output) do
    case get_from_list(list, index) do
      {:ok, elm} ->
        new_output = [elm | output]
        do_get_many_from_list(list, rest_indices, new_output)

      {:error, msg} ->
        {:error, msg}
    end
  end
end
