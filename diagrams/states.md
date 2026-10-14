# Состояния реакции и доступа

Это модель наблюдаемого поведения, а не перечисление значений одного столбца status. Реакции хранятся в reactions, взаимность — в matches, запрет доступа — в user_blocks. Блокировка возможна и до match; на схеме показана только её роль для существующей переписки. Разблокировка не сбрасывает реакции и не удаляет историю.

Пауза анкеты и личные настройки чата ортогональны взаимности: они не превращают Like в Skip и не удаляют match. Полное правило видимости — в [данных и доступе](../privacy/data-handling.md).

![Состояния реакции и доступа](assets/states.svg)

[Открыть SVG](assets/states.svg) · [Открыть PNG](assets/states.png)

## Исходник Mermaid

<details>
<summary>Показать редактируемую схему</summary>

```mermaid
stateDiagram-v2
  accTitle: Реакции и доступ к чату
  accDescr: Состояния описывают пользовательскую связь, а не отдельный status в таблице. Собственный Skip возвращается после нового круга, Like сохраняется, встречный Like даёт match. Блокировка закрывает доступ, не удаляя match.
  direction LR
  [*] --> Unseen
  state "Нет собственной реакции" as Unseen
  state "Собственный Skip" as Skipped
  state "Собственный Like" as Liked
  state "Match: чат доступен" as Matched
  state "Match: доступ заблокирован" as Blocked
  Unseen --> Skipped: Skip
  Skipped --> Unseen: Сброс своих Skip
  Unseen --> Liked: Like, встречного Like нет
  Unseen --> Matched: Like, встречный Like уже есть
  Liked --> Matched: Собеседник ставит Like
  Matched --> Blocked: Блокировка любой стороны
  Blocked --> Matched: Ни одной блокировки не осталось
  note right of Matched
    Пауза анкеты сохраняет чат.
    Очистка и скрытие чата — личные настройки.
    Новое сообщение снимает личное скрытие.
  end note
```

</details>
