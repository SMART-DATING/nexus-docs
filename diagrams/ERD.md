# Актуальная логическая ERD

```mermaid
erDiagram
  users ||--o{ private_contexts : writes
  users ||--o{ profile_photos : uploads
  users ||--o{ profile_properties : owns
  users ||--o{ user_interests : selects
  interests ||--o{ user_interests : selected
  users ||--|| preferences : configures
  users ||--o{ sessions : authenticates
  users ||--o{ reactions : actor_or_target
  users ||--o{ matches : first_or_second
  matches ||--o{ messages : contains
  users ||--o{ messages : sends
  users ||--o{ notifications : receives
  matches ||--o{ notifications : refers
  users ||--o{ user_blocks : actor_or_target
  users ||--o{ chat_preferences : configures
  matches ||--o{ chat_preferences : customized
  users {
    bigint id PK
    varchar email UK
    varchar login UK
    varchar password_hash
    varchar gender
    varchar avatar_key
    bytea avatar_image
    varchar avatar_version
    boolean gallery_migrated
    boolean discovery_hidden
    timestamp last_active_at
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
    bytea image
    varchar demo_resource
    varchar version
  }
  profile_properties {
    bigint id PK
    bigint user_id
    varchar name
    varchar property_value
    boolean visible
  }
  interests {
    bigint id PK
    varchar name UK
    varchar category
  }
  user_interests {
    bigint id PK
    bigint user_id FK
    bigint interest_id FK
  }
  preferences {
    bigint id PK
    bigint user_id FK
    int min_age
    int max_age
    varchar interested_in
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
    boolean read_by_recipient
    varchar text
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
  sessions {
    bigint id PK
    varchar token_hash UK
    bigint user_id
    timestamp expires_at
  }
```

В текущей базе 14 предметных/служебных таблиц, каждая соответствует JPA-сущности. Уникальны email, nullable login, имя интереса, preferences.user_id, пары profile_properties(user_id,name), user_interests(user_id,interest_id), reactions(actor_id,target_id), matches(first_id,second_id), user_blocks(actor_id,target_id), chat_preferences(user_id,match_id).

Актуальная схема — Mermaid выше. `ERD.png` сохранён как прежний снимок схемы до добавления блокировок и настроек чата; он не является текущей ERD.

UserInterest имеет физические FK к UserAccount и Interest, Preference — FK к UserAccount. Остальные связи представлены ID и проверяются сервисом; удаления сущностей в API нет. Перед добавлением удаления нужны полные FK и политика каскадов.

В ранее созданной базе могут остаться старые user_account_interests и users.min_age/max_age. CatalogueData переносит их значения в новые сущности; старые данные сохраняются для восстановления и не являются текущей моделью. Отдельной таблицы Profile нет; фото — profile_photos, личный текст и его версионированный вектор — private_contexts. EmbeddingVector и Recommendation отдельными таблицами не представлены. Исходные avatar_image/avatar_version сохраняются для совместимости после переноса в галерею.
