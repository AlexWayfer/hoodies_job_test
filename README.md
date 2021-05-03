# Тестовое задание для вакансии Ruby developer в Hoodies

## Постановка

В файле `Task.rb` находится программа, выполняющая обработку данных из файла.
Тест показывает как программа должна работать.
В этой программе нужно обработать файл данных `data_large.txt`.

Ожидания от результата:

* корректная обработатка файла data_large.txt;
* проведена оптимизация кода и представлены ее результаты;
* production-ready код;
* применены лучшие практики.

Отчёт в JSON:

- Сколько всего юзеров
- Сколько всего уникальных браузеров
- Сколько всего сессий
- Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом
- По каждому пользователю
  - сколько всего сессий
  - сколько всего времени
  - самая длинная сессия
  - браузеры через запятую
  - Хоть раз использовал IE?
  - Всегда использовал только Хром?
  - даты сессий в порядке убывания через запятую

По возможности использовать [`dry-rb`](https://dry-rb.org/).

## Решение

### Разархивация файла

Неясно, ожидается, что распаковка архива будет происходить в скрипте (всегда приходит архив),
или можно разархивировать вручную перед выполнением. Сделал в скрипте, несложно.

### Чтение файла

Хоть у меня в системе обычный `#read` исполняется быстро, наверняка ожидается
постепенное чтение файла, чтобы не перегружать ОЗУ.

### Запись файла

Непонятно, исходные данные всегда отсортированы или нет (на первый взгляд — да, но вдруг нет),
и могу ли я писать результат так же последовательно (через append mode)
или необходимо держать всё в ОЗУ, так что остановился на последнем.

### `dry-rb`

Тут хватило бы `dry-struct`, но можно притянуть и `dry-monads` для последовательных операций,
и `dry-validation` для валидации входящих данных, и туда же `dry-types` — непонятно,
на чём лучше остановиться. Сделал максимум, пожалуй (`dry-system` не очень понимаю и не очень хочу,
особенно для проекта из одной задачи).

Не понравилось:

*   `Types::Strict::String` требует тип `String`, `Types::Coercible::String` пробует
    конвертировать в `String`, а `Types::String` что делает? Приходит `Integer` — оставляет его?
    Зачем…
    *   Есть метод `.optional`, почему это метод, а не namespace, как с `Coercible` или `Strict`?
        Не однообразно. И что будет при `Types::Strict::String.optional`? Либо строка, либо `nil`,
        либо ошибка? А в других случаях либо попытка конвертации, либо оставляет данные как есть?
        А для `Types::Coercible::String.optional` он попробует конвертировать `nil` в `''`?
    *   Ключ вида `:gteq` для `.constrained` плохо читается и выбивается из Ruby naming.
        Операторы нравятся больше, пример — Sequel.
        Либо блоки, либо `:>= => 18` и `'>=': 18` — валидные формы.
    *   А зачем вообще `Strict`?… Я просто делал подобные вещи
        в [Formalism](https://github.com/AlexWayfer/formalism), и там коерсия почти всегда,
        и в реальных коммерческих проектах всё устраивало, а остальное — дело валидации.
        Зачем исключение, если пришло не `18`, а `'18'`? Избежать данных вида `'#<Object:...'`?
        Не сталкивался, обычно наоборот строка приходит, которую нужно в объект конвертировать,
        и/или коерсия может произойти до входа данных, но ладно.

*   Вот есть в задаче поле `age` у пользователя. Оно не используется нигде.
    Мне его требовать, валидировать, что делать?

*   `time` лучше называть `duration`, а то неоднозначно смотрится рядом с `date`,
    да и вообще вряд ли корректно. Оставил, чтобы не было путаницы с ключами в ожидаемом JSON.

*   Почему нет `Types::Coercible::Date`? Есть `Types::JSON::Date`, но у нас скорее приходит CSV,
    и дата там может быть в любом формате, так что пришлось писать кастомный тип.
