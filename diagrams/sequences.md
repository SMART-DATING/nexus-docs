# Последовательности основных операций

Схемы описывают фактическую последовательность сервисов. Защищённые запросы проходят проверку сессии; транзакционные границы и ошибки уточняются в [архитектуре](../architecture/system-architecture.md) и [API](../architecture/api-contracts.md).

## Сохранение истории

![Сохранение истории](assets/story-sequence.svg)

[SVG](assets/story-sequence.svg) · [PNG](assets/story-sequence.png)

<details>
<summary>Исходник Mermaid</summary>

```mermaid
sequenceDiagram
  accTitle: Сохранение личного рассказа
  accDescr: Только подтверждённый текст передаётся на API, проверяется, кодируется локальной моделью и сохраняется вместе с вектором. Сохранение не публикует рассказ другим людям.
  actor U as Участник
  participant C as React-редактор
  participant A as ApiController
  participant S as ContextService
  participant M as SemanticEncoder
  participant D as База данных
  U->>C: Написать или исправить итог
  Note over U,C: До сохранения черновик остаётся в браузере
  U->>C: Сохранить
  C->>A: POST /contexts/me + Bearer
  A->>A: Сессия и DTO-валидация
  A->>S: save(userId, null, title, content)
  S->>S: trim и проверка длины
  S->>M: encode(content)
  alt Модель доступна
    M-->>S: Нормализованный вектор
    S->>D: Блокировка аккаунта и проверка лимита
    S->>D: История + embedding + modelVersion
    D-->>S: Сохранённая запись
    S-->>A: id, title, content, updatedAt
    A-->>C: 201, собственная история без вектора
    C-->>U: Успешное сохранение
  else Модель отсутствует
    M-->>S: Ошибка 503
    S-->>A: Сохранение не выполнено
    A-->>C: 503 + message
    C-->>U: Причина и возможность повтора
  end
```

</details>

## Следующая подборка

![Следующая подборка](assets/recommendation-sequence.svg)

[SVG](assets/recommendation-sequence.svg) · [PNG](assets/recommendation-sequence.png)

<details>
<summary>Исходник Mermaid</summary>

```mermaid
sequenceDiagram
  accTitle: Получение следующей подборки
  accDescr: Backend читает данные и сохранённые векторы, фильтрует и сортирует кандидатов. Skip сбрасываются только после полного исчерпания новых подходящих анкет. Фото-разрешения формируются только для страницы.
  participant C as React-клиент
  participant S as NexusService
  participant D as База данных
  participant G as GalleryService
  C->>S: POST /recommendations/next?limit=20
  S->>D: Блокировка текущего аккаунта
  S->>D: Профили, настройки, реакции, истории
  D-->>S: Данные и сохранённые векторы
  S->>S: Допуск: готовность, видимость, блокировки, возраст, пол
  S->>S: Свой город первым, затем cosine по убыванию и ID
  alt Новых нет, подходящие Skip есть
    S->>D: Удалить только собственные Skip
    S->>S: Пересчитать очередь
  end
  S->>G: Разрешённые галереи только страницы
  G->>D: Метаданные и актуальная квота
  D-->>G: Без загрузки изображений всей базы
  G-->>S: Разрешённые фото-URL с ticket
  S-->>C: items, skippedCount, cycleRestarted
  Note over C,S: Чужие тексты и векторы в ответ не входят
```

</details>

## Взаимность и сообщение

![Взаимность и сообщение](assets/match-sequence.svg)

[SVG](assets/match-sequence.svg) · [PNG](assets/match-sequence.png)

<details>
<summary>Исходник Mermaid</summary>

```mermaid
sequenceDiagram
  accTitle: Взаимная симпатия и первое сообщение
  accDescr: Два встречных Like создают один match в транзакции. Доступ к сообщениям повторно проверяет участие и блокировку. Чтение истории само не меняет счётчик.
  actor A as Участник А
  actor B as Участник Б
  participant S as NexusService
  participant D as База данных
  A->>S: POST /users/B/like
  S->>D: Заблокировать аккаунты по ID ↑
  S->>S: Проверить доступ и отсутствие повтора
  S->>D: Сохранить Like A → Б
  S-->>A: matched=false
  B->>S: POST /users/A/like
  S->>D: Заблокировать те же аккаунты по ID ↑
  S->>D: Сохранить Like Б → A
  S->>D: Найти встречный Like
  S->>D: Один match + два уведомления
  S-->>B: matched=true, matchId
  A->>S: GET /matches
  S-->>A: Доступный match
  B->>S: POST /matches/id/messages
  S->>S: Участие, блокировка пары
  S->>D: Сообщение и уведомление адресату
  S-->>B: 201, сообщение
  A->>S: GET /matches/id/messages?after=0
  S-->>A: История без изменения прочтения
  A->>S: PATCH /matches/id/read с throughId
  S->>D: Прочитаны входящие до границы
  S-->>A: unreadCount
```

</details>
