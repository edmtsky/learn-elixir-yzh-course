defmodule WorldChamp do
  def sample_champ() do
    [
      {
        :team, "Crazy Bulls",
        [
          {:player, "Big Bull", 22, 545, 99},
          {:player, "Small Bull", 18, 324, 95},
          {:player, "Bull Bob", 19, 32, 45},
          {:player, "Bill The Bull", 23, 132, 85},
          {:player, "Tall Ball Bull", 38, 50, 50},
          {:player, "Bull Dog", 35, 201, 91},
          {:player, "Bull Tool", 29, 77, 96},
          {:player, "Mighty Bull", 22, 145, 98}
        ]
      },
      {
        :team, "Cool Horses",
        [
          {:player, "Lazy Horse", 21, 423, 80},
          {:player, "Sleepy Horse", 23, 101, 35},
          {:player, "Horse Doors", 19, 87, 23},
          {:player, "Rainbow", 21, 200, 17},
          {:player, "HoHoHorse", 20, 182, 44},
          {:player, "Pony", 25, 96, 76},
          {:player, "Hippo", 17, 111, 96},
          {:player, "Hop-Hop", 31, 124, 49}
        ]
      },
      {
        :team, "Fast Cows",
        [
          {:player, "Flash Cow", 18, 56, 34},
          {:player, "Cow Bow", 28, 89, 90},
          {:player, "Boom! Cow", 20, 131, 99},
          {:player, "Light Speed Cow", 21, 201, 98},
          {:player, "Big Horn", 23, 38, 93},
          {:player, "Milky", 25, 92, 95},
          {:player, "Jumping Cow", 19, 400, 98},
          {:player, "Cow Flow", 18, 328, 47}
        ]
      },
      {
        :team, "Fury Hens",
        [
          {:player, "Ben The Hen", 57, 403, 83},
          {:player, "Hen Hen", 20, 301, 56},
          {:player, "Son of Hen", 21, 499, 43},
          {:player, "Beak", 22, 35, 96},
          {:player, "Superhen", 27, 12, 26},
          {:player, "Henman", 20, 76, 38},
          {:player, "Farm Hen", 18, 131, 47},
          {:player, "Henwood", 40, 198, 77}
        ]
      },
      {
        :team, "Extinct Monsters",
        [
          {:player, "T-Rex", 21, 999, 99},
          {:player, "Velociraptor", 29, 656, 99},
          {:player, "Giant Mammoth", 30, 382, 99},
          {:player, "The Big Croc", 42, 632, 99},
          {:player, "Huge Pig", 18, 125, 98},
          {:player, "Saber-Tooth", 19, 767, 97},
          {:player, "Beer Bear", 24, 241, 99},
          {:player, "Pure Horror", 31, 90, 43}
        ]
      }
    ]
  end


  def get_stat(champ) do
    # {num_teams, num_players, avg_age, avg_rating}
    initial_state = {0, 0, 0, 0}

    totals =
      champ
      |> Enum.reduce(initial_state, fn team_item, acc ->
        {:team, _name, players} = team_item
        {num_teams, total_num_players, total_age, total_rating} = acc

        team_stats =
          players
          |> Enum.reduce({0, 0, 0}, fn player_item, per_team_acc ->
            {:player, _name, age, rating, _health} = player_item
            {num_players, sum_age, sum_rating} = per_team_acc
            {num_players + 1, sum_age + age, sum_rating + rating}
          end)

        {team_num_players, team_sum_age, team_sum_rating} = team_stats

        {
          num_teams + 1,
          total_num_players + team_num_players,
          total_age + team_sum_age,
          total_rating + team_sum_rating
        }
      end)

    {num_teams, total_num_players, total_age, total_rating} = totals
    avg_age = total_age / total_num_players
    avg_rating = total_rating / total_num_players

    {num_teams, total_num_players, avg_age, avg_rating}
  end

  def examine_champ(champ) do
    champ
    |> Enum.map(&examine_team/1)
    |> Enum.filter(fn {:team, _name, players} -> length(players) > 5 end)
  end

  def examine_team({:team, name, players}) do
    healthy_players =
      players
      |> Enum.filter(fn player_item ->
        {:player, _name, _age, _rating, health} = player_item
        health >= 50
      end)

    {:team, name, healthy_players}
  end

  def make_pairs(team1, team2) do
    {:team, _name, players1} = team1
    {:team, _name, players2} = team2

    for {:player, name1, _, rating1, _} <- players1,
        {:player, name2, _, rating2, _} <- players2,
        rating1 + rating2 > 600,
        do: {name1, name2}
  end
end
