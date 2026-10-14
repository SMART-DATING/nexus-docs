# Модель данных

Словарь соответствует 14 JPA-сущностям в [backend/entity](https://github.com/SMART-DATING/nexus-backend/tree/main/src/main/java/ru/nexus/entity). Имена столбцов приведены в физическом `snake_case`. Типы ниже логические: конкретный SQL-тип зависит от H2/PostgreSQL и Hibernate.

[Полная ER-диаграмма](../diagrams/ERD.md) · [Правила доступа](../privacy/data-handling.md)

## Таблицы и назначение

| Таблица / сущность | Данные | Ключи и правила |
| --- | --- | --- |
| `users` / `UserAccount` | `id`, `email`, `login`, `password_hash`, `gender`, `discovery_hidden`, `last_active_at`; прежние `avatar_key`, `avatar_image`, `avatar_version`, `gallery_migrated` | PK `id`; уникальные email и nullable login. Email и пароль обязательны. Login до 32, gender до 16. Старые avatar-поля сохранены для переноса |
| `profile_properties` / `ProfileProperty` | `id`, `user_id`, `name`, `property_value`, `visible` | PK `id`; UK (`user_id`, `name`). Ровно четыре поддерживаемых имени поля; `user_id` — логическая ссылка |
| `interests` / `Interest` | `id`, `name`, `category` | PK `id`; UK `name`, до 80 символов; обязательная `category` до 255, сохранена для совместимости |
| `user_interests` / `UserInterest` | `id`, `user_id`, `interest_id` | PK `id`; UK (`user_id`, `interest_id`); физические FK к `users` и `interests` |
| `preferences` / `Preference` | `id`, `user_id`, `min_age`, `max_age`, `interested_in` | PK `id`; уникальный обязательный FK `user_id` → `users`. По умолчанию 18–60, null interested_in трактуется как `all` |
| `private_contexts` / `PrivateContext` | `id`, `user_id`, `title`, `content`, `embedding`, `model_version`, `updated_at` | PK `id`; прочие поля обязательны. Title до 60, content до 6000, embedding JSON-текст до 16000, model_version до 120. Вектор в обычной версии — 312 чисел |
| `profile_photos` / `ProfilePhoto` | `id`, `user_id`, `position`, `image`, `demo_resource`, `version` | PK `id`; user_id, position и version обязательны. Position — с нуля; порядок `position`, затем ID. Бинарный JPEG либо служебный ресурс демо |
| `sessions` / `SessionToken` | `id`, `token_hash`, `user_id`, `expires_at` | PK `id`; UK `token_hash`, хранится SHA-256 токена, не исходный Bearer |
| `reactions` / `Reaction` | `id`, `actor_id`, `target_id`, `liked` | PK `id`; UK (`actor_id`, `target_id`); true = Like, false = Skip. Направленная связь двух участников |
| `matches` / `PairMatch` | `id`, `first_id`, `second_id`, `created_at` | PK `id`; UK (`first_id`, `second_id`). Сервис хранит меньший ID первым; это правило кода, не SQL CHECK |
| `messages` / `ChatMessage` | `id`, `match_id`, `sender_id`, `text`, `created_at`, `read_by_recipient` | PK `id`; text обязательный до 5000. Null прежнего read_by_recipient трактуется как непрочитанное |
| `notifications` / `Notice` | `id`, `user_id`, `match_id`, `text`, `seen`, `created_at` | PK `id`; получатель связан с аккаунтом, уведомление — с match. Выдаётся до 100 последних, затем применяются ограничения чатов |
| `user_blocks` / `UserBlock` | `id`, `actor_id`, `target_id`, `target_name`, `created_at` | PK `id`; UK (`actor_id`, `target_id`); все поля обязательны. Имя до 60 фиксируется при блокировке |
| `chat_preferences` / `ChatPreference` | `id`, `user_id`, `match_id`, `pinned`, `hidden`, `marked_unread`, `cleared_through_id` | PK `id`; UK (`user_id`, `match_id`); user_id/match_id обязательны. Настройки каждой стороны независимы; отсутствие строки означает значения по умолчанию |

## Поля анкеты

| `name` | Допустимое значение API | Видимость |
| --- | --- | --- |
| `display_name` | Непустое имя, до 60 символов | Только публичное |
| `bio` | До 1000 символов, может быть пустым | Выбор владельца |
| `birth_date` | ISO-дата `YYYY-MM-DD`, возраст 18–100 | В UI скрыта по умолчанию; выбор владельца |
| `city` | Непустой город, до 80 символов | Выбор владельца; скрытое значение всё равно участвует в приоритете города |

`property_value` допускает 2000 символов на уровне колонки, но API устанавливает более строгие ограничения. Нельзя считать размер колонки разрешённой длиной пользовательского ввода.

Пол хранится отдельно в `users.gender`: `male`, `female`, `other`, `unspecified`; null старой записи читается как `unspecified`. Предпочтение `other` означает категорию «другой», а не автоматическое вычисление противоположного пола. Пол и предпочтения не передаются как публичные поля анкеты.

## Физические и логические связи

**Физические FK объявлены в JPA только для:** `preferences.user_id`, `user_interests.user_id`, `user_interests.interest_id`. Остальные поля `*_id` являются числовыми ссылками, чья корректность проверяется сервисами. Полная ERD показывает предметные связи, не обещая наличие каждого FK в БД.

Ограничения «до 6 фото», «до 12 историй», допустимые значения пола, возраст, отсутствие самореакции и участие отправителя в match реализованы в DTO/сервисах. Вне API прямое изменение БД может обойти эти проверки.

Отдельных таблиц профиля, чата, рекомендации и вектора нет: профиль собирается из нескольких таблиц, чат определяется match, выдача рассчитывается, а embedding хранится в истории.

## Существующие базы и миграции

`CatalogueData` переносит прежние интересы и возрастные настройки; `GalleryMigration` / `GalleryService` переводят старый аватар в галерею один раз. Старые `user_account_interests` и `users.min_age/max_age` могут оставаться в конкретном файле после обновления. Они не добавляют сущностей в текущую модель и не должны считаться её рабочим источником.

Схема создаётся/обновляется Hibernate (`ddl-auto=update`); отдельной цепочки Flyway/Liquibase нет. Прежде чем вводить удаление аккаунта, нужны полноценные внешние ключи, политика удаления связанных данных и управляемые миграции. [План развития](../roadmap.md).
