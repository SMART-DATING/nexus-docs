# ER-диаграмма

Схема охватывает **14 текущих таблиц**. Связи — логические отношения предметной области; метка FK стоит только у реально объявленных JPA-внешних ключей: preferences.user_id и двух связей user_interests. Повторные линии reactions, matches и user_blocks различают роли двух участников.

Диаграмма содержит основные рабочие поля. Прежние avatar_key/avatar_image/avatar_version/gallery_migrated сохранены в users для совместимости и подробно описаны в [словаре данных](../architecture/data-dictionary.md). Отдельных таблиц профиля, чата и рекомендации нет.

Обозначения: PK — первичный ключ, UK — одиночная уникальность, FK — физическая ссылка. Составные UK: profile_properties(user_id,name), user_interests(user_id,interest_id), reactions(actor_id,target_id), matches(first_id,second_id), user_blocks(actor_id,target_id), chat_preferences(user_id,match_id).

У preferences физически допустимо не более одной строки на аккаунт; сервис создаёт её при регистрации и восстанавливает для прежнего аккаунта при обращении. Чат-настройка создаётся по действию; отсутствие строки означает значения по умолчанию. Ограничения количества фото/историй и корректности прочих ID проверяются кодом, а не всеми необходимыми FK/CHECK в БД.

[Словарь всех полей и ограничений](../architecture/data-dictionary.md) · [JPA-сущности](https://github.com/SMART-DATING/nexus-backend/tree/main/src/main/java/ru/nexus/entity)

![ER-диаграмма](assets/ERD.svg)

[Открыть SVG](assets/ERD.svg) · [Открыть PNG](assets/ERD.png)

## Исходник Mermaid

<details>
<summary>Показать редактируемую схему</summary>

```mermaid
erDiagram
  accTitle: Логическая ER-диаграмма четырнадцати таблиц Nexus
  accDescr: Все предметные связи показаны отдельно для автора и адресата. FK отмечены только у физически объявленных связей Preference и UserInterest.
  direction TB
  users ||--o| preferences : "user_id"
  users ||--o{ profile_properties : "user_id"
  users ||--o{ private_contexts : "user_id"
  users ||--o{ profile_photos : "user_id"
  users ||--o{ user_interests : "user_id"
  interests ||--o{ user_interests : "interest_id"
  users ||--o{ sessions : "user_id"
  users ||--o{ reactions : "actor_id"
  users ||--o{ reactions : "target_id"
  users ||--o{ matches : "first_id"
  users ||--o{ matches : "second_id"
  matches ||--o{ messages : "match_id"
  users ||--o{ messages : "sender_id"
  users ||--o{ notifications : "user_id"
  matches ||--o{ notifications : "match_id"
  users ||--o{ user_blocks : "actor_id"
  users ||--o{ user_blocks : "target_id"
  users ||--o{ chat_preferences : "user_id"
  matches ||--o{ chat_preferences : "match_id"
  users {
    bigint id PK
    varchar email UK
    varchar login UK "nullable"
    varchar password_hash
    varchar gender
    boolean discovery_hidden
    timestamp last_active_at
  }
  preferences {
    bigint id PK
    bigint user_id FK,UK
    int min_age
    int max_age
    varchar interested_in
  }
  profile_properties {
    bigint id PK
    bigint user_id
    varchar name
    varchar property_value
    boolean visible
  }
  private_contexts {
    bigint id PK
    bigint user_id
    varchar title
    varchar content
    varchar embedding
    varchar model_version
    timestamp updated_at
  }
  profile_photos {
    bigint id PK
    bigint user_id
    int position
    binary image
    varchar demo_resource
    varchar version
  }
  user_interests {
    bigint id PK
    bigint user_id FK
    bigint interest_id FK
  }
  interests {
    bigint id PK
    varchar name UK
    varchar category
  }
  sessions {
    bigint id PK
    varchar token_hash UK
    bigint user_id
    timestamp expires_at
  }
  reactions {
    bigint id PK
    bigint actor_id
    bigint target_id
    boolean liked
  }
  matches {
    bigint id PK
    bigint first_id
    bigint second_id
    timestamp created_at
  }
  messages {
    bigint id PK
    bigint match_id
    bigint sender_id
    varchar text
    boolean read_by_recipient
    timestamp created_at
  }
  notifications {
    bigint id PK
    bigint user_id
    bigint match_id
    varchar text
    boolean seen
    timestamp created_at
  }
  user_blocks {
    bigint id PK
    bigint actor_id
    bigint target_id
    varchar target_name
    timestamp created_at
  }
  chat_preferences {
    bigint id PK
    bigint user_id
    bigint match_id
    boolean pinned
    boolean hidden
    boolean marked_unread
    bigint cleared_through_id
  }
```

</details>
