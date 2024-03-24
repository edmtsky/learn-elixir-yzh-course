# Мои решения домашек из учебного курса по языку прогрммирования Elixir


## Способы запустить тесты

- через утилиту `mix`
```sh
cd 03-types-homework
mix test
```

- через низкоуровневый bash-скрипт
```sh
cd 03-types-homework
./run_tests.sh
```

- полностью вручную:
```sh
cd 03-types-homework
elixirc rect.ex && elixir rect_test.exs
elixirc quadratic_equation.ex && elixir quadratic_equation_test.exs
elixirc word_count.ex && elixir word_count_test.exs
```

при ручном запуске скомпилированные файлы(*.beam) будут сохранены
в текущий каталог. при компиляции через bash-скрипт в `_build`


## Что здесь есть

- 01-fizzbuss - пример поэтапной разработки простейшей программы
- 03-types-examples - примеры исходного кода из 2го урока
- 03-types-homework - домашки третьего урока

