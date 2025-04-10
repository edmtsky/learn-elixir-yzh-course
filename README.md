# Мои решения домашек из учебного курса по языку прогрммирования Elixir

## О самом курсе

> [Видео](https://www.youtube.com/playlist?list=PLYuTgpYrBrVKnzanStbVGD09Cdx4YNEpO)
> [Репозиторий курса](https://github.com/yzh44yzh/elixir_course)
> [Как поддержать автора курса](https://boosty.to/yury.zhloba)

## Способы запустить тесты

- через утилиту `mix`
```sh
cd 03-types-homework
mix test
```

- через низкоуровневый bash-скрипт
```sh
cd 03-types-homework
../run_tests.sh

cd 04-homework
../run_tests.sh
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

- timecodes - таймкоды к видео курса.
- articles - переводы статей
- homeworks - мои решения домашек
- 01-fizzbuss - пример поэтапной разработки простейшей программы
- 03-types-examples - примеры исходного кода из 2го урока
- 03-types-homework - домашки третьего урока
- 04-control-flow - ветвления в коде, примеры: case, function clauese, guards
- 05-list-n-recursion - коллекции и рекурсия
- 06-hof - функции высшего порядка, модуль Stream и ленивые вычисления
- 07-user-data-types - начало создания проекта и моделирование доменной области

# Refs

https://www.erlang.org/doc/efficiency_guide/myths.html
