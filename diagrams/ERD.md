# Актуальная логическая ERD

```mermaid
erDiagram
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
  users {
    bigint id PK
    varchar email UK
    varchar password_hash
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
  sessions {
    bigint id PK
    varchar token_hash UK
    bigint user_id
    timestamp expires_at
  }
```

В новой базе 10 предметных/служебных таблиц, каждая соответствует JPA-сущности. Уникальны email, имя интереса, preferences.user_id, пары profile_properties(user_id,name), user_interests(user_id,interest_id), reactions(actor_id,target_id), matches(first_id,second_id).

UserInterest имеет физические FK к UserAccount и Interest, Preference — FK к UserAccount. Остальные связи представлены ID и проверяются сервисом; удаления сущностей в API нет. Перед добавлением удаления нужны полные FK и политика каскадов.

В ранее созданной базе могут остаться старые user_account_interests и users.min_age/max_age. CatalogueData переносит их значения в новые сущности; старые данные сохраняются для восстановления и не являются текущей моделью. Profile, Photo, EmbeddingVector и Recommendation как таблицы отсутствуют.

