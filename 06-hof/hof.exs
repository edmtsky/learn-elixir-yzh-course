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

  def split_by_age(users, age_limit) do
    pred1 = fn {:user, _, _, age} -> age < age_limit end
    pred2 = fn user -> not pred1.(user) end
    # pred2 = fn {:user, _, _, age} -> age >= age_limit end

    users1 = Enum.filter(users, pred1)
    users2 = Enum.filter(users, pred2)
    {users1, users2}
  end
end
