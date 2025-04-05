defmodule HOF do

  def test_data() do
    # {tag, id, name, age}
    [
      {:user, 1, "Bob", 15},
      {:user, 2, "Bill", 25},
      {:user, 3, "Helen", 10},
      {:user, 4, "Kate", 11},
      {:user, 5, "Yura", 31},
      {:user, 6, "Dima", 65},
      {:user, 7, "Yana", 35},
      {:user, 8, "Diana", 41},
    ]
  end

  def split_by_age_legacy(users, age_limit) do
    pred1 = fn {:user, _, _, age} -> age < age_limit end
    pred2 = fn user -> not pred1.(user) end
    # pred2 = fn {:user, _, _, age} -> age >= age_limit end

    users1 = Enum.filter(users, pred1)
    users2 = Enum.filter(users, pred2)
    {users1, users2}
  end

  """
  Enum.reduce/3 -> final_acc
  arg:
   - collection
   - accumulator
   - reducer (folding function)

  reducer/2 -> new_acc
  arg:
   - item
   - acc
  """

  def get_avg_age(users) do
    {total_users, total_age} =
      Enum.reduce(users, {0, 0}, &avg_age_reducer/2)

     total_age / total_users
  end

  def avg_age_reducer({:user, _, _, age}, {num_users, total_age}) do
    {num_users + 1, total_age + age}
  end


  def split_by_age(users, age_limit) do
    Enum.reduce(
      users,
      {[], []}, # acc
      fn {:user, _, _, age} = user, {younger_list, older_list} ->
        if age < age_limit do
          {[user | younger_list], older_list}
        else
          {younger_list, [user | older_list]}
        end
      end
    )
  end

  def get_oldest_user(users) do
    # [first_user | rest_users] = users

    Enum.reduce(
      users, # rest_users,  # collection
      # first_user,         # accumulator
      fn curr_user, acc ->  # reducer
        {:user, _, _, curr_age} = curr_user
        {:user, _, _, max_age} = acc
        if curr_age > max_age do
          curr_user
        else
          acc
        end
    end)
  end

  @type user :: {:user, integer(), String.t(), integer()}
  @type attr_type :: :id | :name | :age

  @spec sort_by_attr([user()], attr_type()) :: [user()]
  def sort_by_attr(users, attr) do
    sorter =
      case attr do
        :id -> &compare_by_id/2
        :name -> &compare_by_name/2
        :age -> &compare_by_age/2
      end
    Enum.sort(users, sorter)
  end

  def compare_by_id(user1, user2) do
    {:user, id1, _, _} = user1
    {:user, id2, _, _} = user2
    id1 < id2
  end

  def compare_by_name(user1, user2) do
    {:user, _, name1, _} = user1
    {:user, _, name2, _} = user2
    name1 < name2
  end

  def compare_by_age(user1, user2) do
    {:user, _, _, age1} = user1
    {:user, _, _, age2} = user2
    age1 < age2
  end
end


