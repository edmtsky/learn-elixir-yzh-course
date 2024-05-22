defmodule RecursionAcc do
  @moduledoc """
  iex recursion_acc.exs
  iex> alias RecursionAcc, as: R
  RecursionAcc
  iex> users = R.test_data()
  ...

  R.filter_adult(user)
  [{:user, 1, "Bob", 23}, {:user, 2, "Helen", 20}, {:user, 5, "Yury", 46}]

  iex> R.get_id_name(users)
  [{1, "Bob"}, {2, "Helen"}, {3, "Bil"}, {4, "Kate"}, {5, "Yury"}]

  iex> R.split_adults_and_childs(users)
  {[{:user, 1, "Bob", 23}, {:user, 2, "Helen", 20}, {:user, 5, "Yury", 46}],
   [{:user, 3, "Bil", 15}, {:user, 4, "Kate", 10}]}


  R.get_avg_age(users)
  22.8

  (23 + 20 + 46 + 15 + 10) /5
  22.8
  """

  def test_data do
    [
      {:user, 1, "Bob", 23},
      {:user, 2, "Helen", 20},
      {:user, 3, "Bil", 15},
      {:user, 4, "Kate", 10},
      {:user, 5, "Yury", 46}
    ]
  end

  #
  # Example-1: filtering

  def filter_adult(users) do
    do_filter_adult(users, [])
  end

  defp do_filter_adult([], acc), do: Enum.reverse(acc)

  defp do_filter_adult([user | users], acc) do
    {:user, _id, _name, age} = user

    if age >= 16 do
      # put to acc
      do_filter_adult(users, [user | acc])
    else
      do_filter_adult(users, acc)
    end
  end

  #
  # Example-2: mapping

  def get_id_name(users) do
    do_get_id_name(users, [])
  end

  defp do_get_id_name([], acc), do: Enum.reverse(acc)

  # def do_get_id_name([user | users], acc) do
  defp do_get_id_name([{:user, id, name, _age} | users], acc) do
    do_get_id_name(users, [{id, name} | acc])
  end

  #
  # Example-3: custom acc

  def split_adults_and_childs_tuple(users) do
    adults = []
    childs = []
    acc = {adults, childs}
    do_split_adults_and_childs_tuple(users, acc)
  end

  defp do_split_adults_and_childs_tuple([], {adults, childs}) do
    {
      Enum.reverse(adults),
      Enum.reverse(childs)
    }
  end

  defp do_split_adults_and_childs_tuple([user | users], {adults, childs}) do
    {:user, _id, _name, age} = user

    if age >= 16 do
      do_split_adults_and_childs(users, {[user | adults], childs})
    else
      do_split_adults_and_childs(users, {adults, [user | childs]})
    end
  end

  #
  # Map as acc

  def split_adults_and_childs(users) do
    acc = %{
      adults: [],
      childs: []
    }

    do_split_adults_and_childs(users, acc)
  end

  defp do_split_adults_and_childs([], acc) do
    %{
      adults: Enum.reverse(acc.adults),
      childs: Enum.reverse(acc.childs)
    }
  end

  defp do_split_adults_and_childs([user | users], acc) do
    {:user, _id, _name, age} = user

    new_acc =
      if age >= 16 do
        # put new  element(user) into acc.adults:
        %{acc | adults: [user | acc.adults]}

        # another way to do it via "update_in":
        # update_in(acc, [:adults], fn list -> [user | list] end)
        #           map      ^       ^^^^^^^^^^^^^^^^^^^^^^^^^^^
        #              path-in-map   callback to update value for given key
        # same as macro:
        # update_in(acc.adults, fn list -> [user | list] end)
      else
        %{acc | childs: [user | acc.childs]}
      end

    do_split_adults_and_childs(users, new_acc)
  end

  #
  # Example-4: avg age. acc is number

  def get_avg_age(users) do
    acc = 0
    total_age = get_total_age(users, acc)
    total_users = length(users)
    total_age / total_users
  end

  defp get_total_age([], acc_total_age), do: acc_total_age

  defp get_total_age([user | users], acc_total_age) do
    {:user, _id, _name, age} = user
    get_total_age(users, age + acc_total_age)
  end
end
