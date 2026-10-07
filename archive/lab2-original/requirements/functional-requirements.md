# Nexus — Функциональные требования

**Функциональные требования (Functional Requirements, FR)** — детальное описание всех функций и возможностей, которые система должна предоставить пользователям. Требования организованы по модулям с приоритизацией: **MUST** (MVP), **SHOULD** (желательно), **COULD** (будущее).

---

## 📊 Легенда приоритизации

| Приоритет | Обозначение | Описание |
|-----------|-------------|---------|
| 🔴 **MUST** | Обязательно | Критично для MVP (ЛР №2) |
| 🟡 **SHOULD** | Желательно | Улучшает опыт, но не критично |
| 🟢 **COULD** | Возможно | Может быть реализовано после MVP |

---

## 🔐 Модуль 1. Аутентификация и учётная запись

### FR-AUTH-01 — Регистрация пользователя 🔴 MUST

**Описание:**  
Система должна позволять неавторизованному пользователю (гость) зарегистрировать новую учётную запись по email и паролю.

**API Endpoint:**
```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "SecurePass123!"
}

Response 201:
{
  "id": 1,
  "email": "john@example.com",
  "created_at": "2024-01-15T10:30:00Z"
}
```

**Бизнес-правила:**
- ✅ Email должен быть уникален в системе
- ✅ Должна быть валидация формата email
- ✅ Пароль должен быть зашифрован перед сохранением (BCrypt)
- ✅ После регистрации пользователь **не авторизуется автоматически** (нужен login)

**Связь:** BR-01 (Безопасность учётных записей)

---

### FR-AUTH-02 — Валидация при регистрации 🔴 MUST

**Описание:**  
Система должна проверять корректность данных регистрации и возвращать понятные сообщения об ошибках.

**Правила валидации:**
| Поле | Правило | Пример ошибки |
|------|---------|---------------|
| **Email** | Формат RFC 5322 | `"Invalid email format"` |
| **Email** | Уникальность | `"Email already registered"` |
| **Пароль** | Минимум 8 символов | `"Password too short"` |
| **Пароль** | Буквы + цифры + спец.символы | `"Password too weak"` |

**Примеры ответов:**
```json
// Некорректный email
{
  "error": "INVALID_EMAIL",
  "message": "Email format is invalid"
}

// Email уже зарегистрирован
{
  "error": "EMAIL_EXISTS",
  "message": "This email is already registered"
}

// Слабый пароль
{
  "error": "WEAK_PASSWORD",
  "message": "Password must contain uppercase, lowercase, numbers and special characters"
}
```

---

### FR-AUTH-03 — Авторизация (Login) 🔴 MUST

**Описание:**  
Система должна позволять авторизованному пользователю войти в приложение, предоставив email и пароль.

**API Endpoint:**
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "SecurePass123!"
}

Response 200:
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "user_id": 1
}
```

**Бизнес-правила:**
- ✅ Проверить наличие пользователя по email
- ✅ Сравнить введённый пароль с сохранённым хешем
- ✅ Если ошибка — вернуть неспецифичное сообщение (не "email не найден", а "Неверные учётные данные")
- ✅ Логировать попытки входа (для безопасности)

**Негативные сценарии:**
```json
// Неверный email или пароль
{
  "error": "INVALID_CREDENTIALS",
  "message": "Invalid email or password"
}

// Пользователь деактивирован
{
  "error": "USER_DISABLED",
  "message": "This account has been disabled"
}
```

---

### FR-AUTH-04 — Токен доступа (JWT) 🔴 MUST

**Описание:**  
После успешной авторизации backend выдаёт **JWT токен**, который используется для защиты последующих запросов.

**Технические требования:**
- ✅ Используется **JWT (JSON Web Token)** стандарт
- ✅ Токен содержит `user_id`, `email`, срок действия (`exp`)
- ✅ Срок действия токена: **1 час** (для MVP)
- ✅ Клиент передаёт токен в заголовке `Authorization: Bearer {token}`
- ✅ Backend проверяет валидность токена перед каждым защищённым запросом

**Пример использования токена:**
```http
GET /api/users/me
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

Response 200:
{
  "id": 1,
  "email": "john@example.com",
  "name": "John Doe"
}
```

**Обработка истёкшего токена:**
```json
{
  "error": "TOKEN_EXPIRED",
  "message": "Your session has expired. Please login again.",
  "status": 401
}
```

**Связь:** NFR-03 (Безопасность), BR-09 (Контроль доступа)

---

### FR-AUTH-05 — Получение текущего пользователя 🔴 MUST

**Описание:**  
Авторизованный пользователь должен иметь возможность получить данные собственной учётной записи.

**API Endpoint:**
```http
GET /api/users/me
Authorization: Bearer {token}

Response 200:
{
  "id": 1,
  "email": "john@example.com",
  "name": "John Doe",
  "bio": "Software developer interested in AI",
  "created_at": "2024-01-15T10:30:00Z",
  "profile_complete": true
}
```

**Требования:**
- ✅ Требует валидный JWT токен
- ✅ Возвращает данные **только текущего пользователя**
- ✅ Не требует передачи user_id в URL (берётся из токена)

---

### FR-AUTH-06 — Выход (Logout) 🟡 SHOULD

**Описание:**  
Клиент должен позволять пользователю завершить сессию (выйти).

**API Endpoint:**
```http
POST /api/auth/logout
Authorization: Bearer {token}

Response 204 No Content
```

**Реализация:**
- ✅ Frontend удаляет токен из localStorage/sessionStorage
- ✅ Backend может добавить токен в чёрный список (если требуется немедленная инвалидация)
- ✅ На MVP этапе достаточно удаления токена на клиенте

---

## 👤 Модуль 2. Профиль пользователя

### FR-PROFILE-01 — Просмотр собственного профиля 🔴 MUST

**Описание:**  
Авторизованный пользователь должен иметь возможность просмотреть собственный профиль со всеми данными.

**API Endpoint:**
```http
GET /api/profiles/me
Authorization: Bearer {token}

Response 200:
{
  "user_id": 1,
  "name": "John Doe",
  "bio": "Software developer and AI enthusiast",
  "age": 28,
  "city": "Helsinki",
  "profile_photo_url": "https://cdn.nexus.app/photos/1.jpg",
  "interests": [
    { "id": 1, "name": "Technology" },
    { "id": 5, "name": "Travel" }
  ],
  "preferences": {
    "min_age": 22,
    "max_age": 35,
    "max_distance_km": 50
  },
  "profile_complete": true
}
```

---

### FR-PROFILE-02 — Редактирование профиля 🔴 MUST

**Описание:**  
Пользователь должен иметь возможность изменить поля своего профиля.

**API Endpoint:**
```http
PUT /api/profiles/me
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "John Doe",
  "bio": "Updated bio",
  "age": 29,
  "city": "Helsinki"
}

Response 200:
{
  "user_id": 1,
  "name": "John Doe",
  "bio": "Updated bio",
  ...
}
```

**Редактируемые поля:**
- ✅ Отображаемое имя (name)
- ✅ Описание профиля (bio)
- ✅ Возраст (age)
- ✅ Город/Местоположение (city)
- ❌ Email изменяется отдельно (не в этом API)
- ❌ user_id, created_at (только чтение)

**Валидация:**
- Имя: 2-100 символов
- Bio: 0-1000 символов
- Age: 18-120 лет
- City: 2-100 символов

---

### FR-PROFILE-03 — Фотографии профиля 🟡 SHOULD

**Описание:**  
Пользователь должен иметь возможность загрузить и удалить фотографии профиля.

**API Endpoints:**
```http
// Загрузка фото
POST /api/profiles/me/photos
Authorization: Bearer {token}
Content-Type: multipart/form-data

Form Data:
  - file: <image_file>

Response 201:
{
  "photo_id": 42,
  "url": "https://cdn.nexus.app/photos/user_1_photo_42.jpg",
  "created_at": "2024-01-15T10:30:00Z"
}

// Удаление фото
DELETE /api/profiles/me/photos/{photo_id}
Authorization: Bearer {token}

Response 204 No Content
```

**Требования:**
- ✅ Поддерживаемые форматы: JPEG, PNG
- ✅ Максимальный размер: 5 MB
- ✅ Автоматическое сжатие и оптимизация
- ✅ Максимум 5 фотографий на профиль

---

### FR-PROFILE-04 — Просмотр чужого профиля в рекомендации 🔴 MUST

**Описание:**  
Пользователь должен видеть основные данные другого пользователя при просмотре рекомендации.

**API Endpoint:**
```http
GET /api/recommendations/users/{user_id}
Authorization: Bearer {token}

Response 200:
{
  "user_id": 42,
  "name": "Jane Smith",
  "age": 26,
  "city": "Helsinki",
  "bio": "Passionate about travel and photography",
  "profile_photo_url": "https://cdn.nexus.app/photos/42.jpg",
  "interests": [
    { "id": 1, "name": "Travel" },
    { "id": 3, "name": "Photography" }
  ],
  "compatibility_score": 0.82  // Если реализовано FR-REC-05
}
```

**Требования:**
- ✅ Показывать **основные поля** (имя, возраст, город, фото)
- ✅ **Не показывать** email, пароль, приватные данные
- ✅ Показывать интересы (для расчёта совместимости)

---

## 🎯 Модуль 3. Интересы

### FR-INTEREST-01 — Получение справочника интересов 🔴 MUST

**Описание:**  
Система должна предоставлять справочник доступных интересов для выбора пользователем.

**API Endpoint:**
```http
GET /api/interests
Authorization: не требуется

Response 200:
{
  "interests": [
    { "id": 1, "name": "Technology" },
    { "id": 2, "name": "Sports" },
    { "id": 3, "name": "Travel" },
    { "id": 4, "name": "Photography" },
    { "id": 5, "name": "Music" },
    { "id": 6, "name": "Reading" },
    { "id": 7, "name": "Cooking" }
  ],
  "total": 7
}
```

**Требования:**
- ✅ Список интересов **предопределён** (администратор добавляет через backend)
- ✅ На MVP достаточно 7-15 интересов
- ✅ Можно использовать кеширование (интересы меняются редко)

---

### FR-INTEREST-02 — Добавление интересов пользователю 🔴 MUST

**Описание:**  
Пользователь должен иметь возможность добавить интересы к своему профилю.

**API Endpoint:**
```http
POST /api/profiles/me/interests
Authorization: Bearer {token}
Content-Type: application/json

{
  "interest_ids": [1, 3, 5]  // Technology, Travel, Music
}

Response 201:
{
  "user_id": 1,
  "interests": [
    { "id": 1, "name": "Technology" },
    { "id": 3, "name": "Travel" },
    { "id": 5, "name": "Music" }
  ]
}
```

**Требования:**
- ✅ Передавать массив interest_ids
- ✅ Валидировать, что интересы существуют в справочнике
- ✅ Минимум 1 интерес для включения в рекомендации (правило из FR-REC-03)

---

### FR-INTEREST-03 — Удаление интереса 🔴 MUST

**Описание:**  
Пользователь должен иметь возможность удалить интерес из своего профиля.

**API Endpoint:**
```http
DELETE /api/profiles/me/interests/{interest_id}
Authorization: Bearer {token}

Response 204 No Content
```

---

### FR-INTEREST-04 — Защита от дублей 🔴 MUST

**Описание:**  
Система не должна допускать добавление одного и того же интереса дважды.

**Реализация:**
- ✅ На уровне БД: уникальное ограничение `UNIQUE (user_id, interest_id)`
- ✅ На уровне приложения: проверка перед сохранением
- ✅ При попытке добавить дубль: вернуть ошибку

**Ошибка:**
```json
{
  "error": "DUPLICATE_INTEREST",
  "message": "This interest is already added to your profile"
}
```

---

## 🎨 Модуль 4. Предпочтения

### FR-PREF-01 — Сохранение предпочтений 🔴 MUST

**Описание:**  
Пользователь должен иметь возможность указать предпочтения, влияющие на получение рекомендаций.

**API Endpoint:**
```http
POST /api/profiles/me/preferences
Authorization: Bearer {token}
Content-Type: application/json

{
  "min_age": 22,
  "max_age": 35,
  "max_distance_km": 50
}

Response 201:
{
  "user_id": 1,
  "preferences": {
    "min_age": 22,
    "max_age": 35,
    "max_distance_km": 50,
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

**Параметры предпочтений:**
| Параметр | Тип | Ограничения | Обязателен |
|----------|-----|-------------|-----------|
| `min_age` | int | 18-100 | ✅ Да |
| `max_age` | int | 18-100, >= min_age | ✅ Да |
| `max_distance_km` | int | 0-1000 | ✅ Да |

**Валидация:**
- ✅ min_age < max_age
- ✅ min_age >= 18
- ✅ max_age <= 100
- ✅ max_distance_km >= 0

---

### FR-PREF-02 — Изменение предпочтений 🔴 MUST

**Описание:**  
Пользователь должен иметь возможность обновить существующие предпочтения.

**API Endpoint:**
```http
PUT /api/profiles/me/preferences
Authorization: Bearer {token}
Content-Type: application/json

{
  "min_age": 20,
  "max_age": 40,
  "max_distance_km": 100
}

Response 200:
{
  "user_id": 1,
  "preferences": {
    "min_age": 20,
    "max_age": 40,
    "max_distance_km": 100,
    "updated_at": "2024-01-15T10:45:00Z"
  }
}
```

---

## 💡 Модуль 5. Рекомендации

### FR-REC-01 — Получение рекомендаций 🔴 MUST

**Описание:**  
Система должна возвращать авторизованному пользователю список рекомендованных профилей на основе совместимости.

**API Endpoint:**
```http
GET /api/recommendations?limit=10&offset=0
Authorization: Bearer {token}

Response 200:
{
  "recommendations": [
    {
      "user_id": 42,
      "name": "Jane Smith",
      "age": 26,
      "city": "Helsinki",
      "bio": "Travel enthusiast",
      "profile_photo_url": "https://cdn.nexus.app/photos/42.jpg",
      "interests": [
        { "id": 1, "name": "Travel" },
        { "id": 3, "name": "Photography" }
      ]
    },
    {
      "user_id": 55,
      "name": "Sarah Johnson",
      ...
    }
  ],
  "total": 15,
  "limit": 10,
  "offset": 0
}
```

**Требования:**
- ✅ Требует авторизации (JWT токен)
- ✅ Возвращает список профилей, отсортированных по релевантности
- ✅ Поддерживает пагинацию (limit, offset)
- ✅ Максимум 100 элементов на странице

---

### FR-REC-02 — Исключение самого пользователя 🔴 MUST

**Описание:**  
Пользователь не должен попадать в собственные рекомендации.

**Реализация:**
```sql
-- В SQL запросе исключить текущего пользователя
SELECT * FROM users 
WHERE user_id != current_user_id
  AND (другие условия...)
```

---

### FR-REC-03 — Учёт интересов при рекомендации 🔴 MUST

**Описание:**  
При расчёте рекомендаций система должна учитывать **совместимость по интересам**.

**Алгоритм:**
```
1. Получить интересы текущего пользователя
2. Для каждого кандидата:
   a. Найти пересечение интересов (common_interests)
   b. Рассчитать score совместимости:
      compatibility = common_interests / total_interests * 100
   c. Отсортировать по убыванию
```

**Пример:**
```
Пользователь A: [Technology, Travel, Music]
Кандидат B: [Travel, Music, Photography]

Пересечение: [Travel, Music] = 2 интереса
Total: 3 интереса пользователя A
Compatibility Score = 2 / 3 = 0.67 (67%)
```

**Требования:**
- ✅ Рассчитывать совместимость для каждого кандидата
- ✅ Сортировать по score в убывающем порядке
- ✅ Только профили с хотя бы одним общим интересом (score > 0)

---

### FR-REC-04 — Учёт истории взаимодействий 🔴 MUST

**Описание:**  
Система должна учитывать предыдущие Like/Skip и не выдавать обработанные профили как новые рекомендации.

**Реализация:**
```sql
-- Исключить уже обработанные профили
SELECT * FROM users u
WHERE u.id NOT IN (
  SELECT target_user_id FROM likes WHERE user_id = current_user_id
  UNION
  SELECT target_user_id FROM skips WHERE user_id = current_user_id
)
  AND (другие условия)
```

**Требования:**
- ✅ Исключить профили, на которые пользователь уже ставил Like
- ✅ Исключить профили, которые пользователь уже пропустил (Skip)
- ✅ Каждый раз запрос берёт актуальную историю

---

### FR-REC-05 — Score совместимости 🟡 SHOULD

**Описание:**  
Для каждой рекомендации должен рассчитываться и возвращаться **показатель совместимости** (score).

**API Endpoint:**
```http
GET /api/recommendations?limit=10
Authorization: Bearer {token}

Response 200:
{
  "recommendations": [
    {
      "user_id": 42,
      "name": "Jane Smith",
      "compatibility_score": 0.82,  // ← Score
      ...
    },
    {
      "user_id": 55,
      "name": "Sarah Johnson",
      "compatibility_score": 0.71,
      ...
    }
  ]
}
```

**Расчёт Score:**
- Базовая формула: `score = common_interests / max(user_interests, candidate_interests)`
- Результат: число от 0 до 1 (или 0-100%)

---

### FR-REC-06 — Сохранение результата рекомендации 🟡 SHOULD

**Описание:**  
Факт показанной рекомендации и рассчитанный score должны сохраняться в БД для аналитики и отладки.

**Таблица в БД:**
```sql
CREATE TABLE recommendations_history (
  id SERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL,
  target_user_id BIGINT NOT NULL,
  compatibility_score DECIMAL(3,2),
  shown_at TIMESTAMP DEFAULT NOW(),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (target_user_id) REFERENCES users(id)
);
```

**Использование:**
- ✅ Анализ: какие рекомендации были показаны
- ✅ Отладка: проверить корректность расчётов
- ✅ Отдельная API для получения истории (опционально)

---

### FR-REC-07 — ML и Embedding 🟢 COULD

**Описание:**  
Система **может** учитывать векторное представление (embedding) текста профиля для улучшения рекомендаций.

**Примечание:** Для MVP это не требуется. Может быть добавлено на этапе оптимизации.

---

## 👍 Модуль 6. Реакции и Match

### FR-LIKE-01 — Like профиля 🔴 MUST

**Описание:**  
Пользователь должен иметь возможность поставить Like рекомендованному профилю.

**API Endpoint:**
```http
POST /api/likes
Authorization: Bearer {token}
Content-Type: application/json

{
  "target_user_id": 42
}

Response 201:
{
  "like_id": 1,
  "user_id": 1,
  "target_user_id": 42,
  "match_created": false,  // true если есть обратный Like
  "created_at": "2024-01-15T10:30:00Z"
}
```

**Требования:**
- ✅ Требует авторизации
- ✅ Целевой профиль должен существовать
- ✅ Нельзя лайкнуть самого себя (проверка на уровне БД: `CHECK (user_id != target_user_id)`)
- ✅ Автоматически проверяет наличие обратного Like

**Ответ при успехе:**
```json
{
  "like_id": 1,
  "match_created": true,  // ← Если есть обратный Like
  "match_id": 99          // ← ID созданного Match
}
```

---

### FR-LIKE-02 — Skip профиля 🔴 MUST

**Описание:**  
Пользователь должен иметь возможность пропустить (Skip) рекомендованный профиль.

**API Endpoint:**
```http
POST /api/skips
Authorization: Bearer {token}
Content-Type: application/json

{
  "target_user_id": 42
}

Response 201:
{
  "skip_id": 1,
  "user_id": 1,
  "target_user_id": 42,
  "created_at": "2024-01-15T10:30:00Z"
}
```

**Требования:**
- ✅ Требует авторизации
- ✅ Целевой профиль должен существовать
- ✅ Пропущенный профиль не должен появиться в новых рекомендациях (если нет специального правила)

---

### FR-LIKE-03 — Защита от повторной реакции 🔴 MUST

**Описание:**  
Система не должна создавать дублирующую реакцию для одной и той же пары.

**Реализация:**
```sql
-- На уровне БД
CREATE TABLE likes (
  user_id BIGINT NOT NULL,
  target_user_id BIGINT NOT NULL,
  PRIMARY KEY (user_id, target_user_id),  -- ← Уникальность пары
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (target_user_id) REFERENCES users(id),
  CHECK (user_id != target_user_id)
);
```

**При попытке повторного Like:**
```json
{
  "error": "DUPLICATE_LIKE",
  "message": "You have already liked this user"
}
```

---

### FR-MATCH-01 — Автоматическое создание Match 🔴 MUST

**Описание:**  
Когда два пользователя ставят Like друг другу, система должна **автоматически создать Match**.

**Сценарий:**
```
Пользователь A ставит Like пользователю B
  ↓
System проверяет: есть ли Like от B к A?
  ↓ Нет
Like от B к A уже существует
  ↓
System создаёт новый Match
```

**API Ответ:**
```json
{
  "like_id": 1,
  "user_id": 1,
  "target_user_id": 42,
  "match_created": true,
  "match_id": 99
}
```

**Создаваемый Match:**
```sql
INSERT INTO matches (user_1_id, user_2_id, created_at)
VALUES (1, 42, NOW());

-- Таблица matches
CREATE TABLE matches (
  id SERIAL PRIMARY KEY,
  user_1_id BIGINT NOT NULL,
  user_2_id BIGINT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE (user_1_id, user_2_id),  -- ← Гарантирует одну пару
  FOREIGN KEY (user_1_id) REFERENCES users(id),
  FOREIGN KEY (user_2_id) REFERENCES users(id)
);
```

**Действия при создании Match:**
- ✅ Создать запись в таблице matches
- ✅ Создать уведомления обоим пользователям (FR-NOTIF-01)
- ✅ Отправить ответ первому пользователю, что Match создан

---

### FR-MATCH-02 — Получение списка Match 🔴 MUST

**Описание:**  
Пользователь должен иметь возможность получить список своих взаимных совпадений (Match).

**API Endpoint:**
```http
GET /api/matches?limit=20&offset=0
Authorization: Bearer {token}

Response 200:
{
  "matches": [
    {
      "match_id": 99,
      "user_id": 42,
      "name": "Jane Smith",
      "age": 26,
      "city": "Helsinki",
      "profile_photo_url": "https://cdn.nexus.app/photos/42.jpg",
      "matched_at": "2024-01-15T10:30:00Z"
    },
    {
      "match_id": 100,
      "user_id": 55,
      "name": "Sarah Johnson",
      ...
    }
  ],
  "total": 5,
  "limit": 20,
  "offset": 0
}
```

**Требования:**
- ✅ Возвращать только Match текущего пользователя
- ✅ Поддерживать пагинацию
- ✅ Сортировать по дате (новые сверху)

---

### FR-MATCH-03 — Уникальность Match 🔴 MUST

**Описание:**  
Между одной парой пользователей не должно существовать нескольких одинаковых активных Match.

**Реализация:**
```sql
-- Уникальное ограничение в БД
CREATE TABLE matches (
  id SERIAL PRIMARY KEY,
  user_1_id BIGINT NOT NULL,
  user_2_id BIGINT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE (user_1_id, user_2_id),
  FOREIGN KEY (user_1_id) REFERENCES users(id),
  FOREIGN KEY (user_2_id) REFERENCES users(id)
);
```

**Логика:**
- При попытке создать второе Match для той же пары: вернуть ошибку или игнорировать
- На бизнес-уровне: один Match = одна пара пользователей

---

## 💬 Модуль 7. Сообщения

### FR-MSG-01 — Отправка сообщения 🔴 MUST

**Описание:**  
Участник Match должен иметь возможность отправить текстовое сообщение другому участнику.

**API Endpoint:**
```http
POST /api/matches/{match_id}/messages
Authorization: Bearer {token}
Content-Type: application/json

{
  "text": "Hi! How are you doing?"
}

Response 201:
{
  "message_id": 1,
  "match_id": 99,
  "sender_id": 1,
  "text": "Hi! How are you doing?",
  "created_at": "2024-01-15T10:30:00Z"
}
```

**Требования:**
- ✅ Требует авторизации
- ✅ Match должен существовать
- ✅ Текущий пользователь должен быть участником Match (иначе 403 Forbidden)
- ✅ Сообщение не должно быть пустым (валидация)
- ✅ Максимальная длина: 5000 символов

**Валидация:**
```json
{
  "error": "EMPTY_MESSAGE",
  "message": "Message text cannot be empty"
}
```

---

### FR-MSG-02 — История сообщений 🔴 MUST

**Описание:**  
Пользователь должен иметь возможность получить историю сообщений конкретного Match в хронологическом порядке.

**API Endpoint:**
```http
GET /api/matches/{match_id}/messages?limit=50&offset=0
Authorization: Bearer {token}

Response 200:
{
  "messages": [
    {
      "message_id": 1,
      "match_id": 99,
      "sender_id": 1,
      "sender_name": "John Doe",
      "text": "Hi! How are you doing?",
      "created_at": "2024-01-15T10:30:00Z",
      "read": true
    },
    {
      "message_id": 2,
      "match_id": 99,
      "sender_id": 42,
      "sender_name": "Jane Smith",
      "text": "Great! How about you?",
      "created_at": "2024-01-15T10:35:00Z",
      "read": false
    }
  ],
  "total": 2,
  "limit": 50,
  "offset": 0
}
```

**Требования:**
- ✅ Сортировка по дате (от старых к новым)
- ✅ Поддержка пагинации
- ✅ Показывать информацию об отправителе (name, avatar)

---

### FR-MSG-03 — Контроль доступа к сообщениям 🔴 MUST

**Описание:**  
Пользователь, не являющийся участником Match, не должен иметь доступ к сообщениям.

**Реализация:**
```java
@GetMapping("/{matchId}/messages")
public ResponseEntity<?> getMessages(@PathVariable Long matchId) {
    Long currentUserId = getCurrentUserId();
    Match match = matchRepository.findById(matchId);
    
    // Проверка: является ли пользователь участником
    if (!match.isParticipant(currentUserId)) {
        return ResponseEntity.status(403).body("Forbidden");
    }
    
    return ResponseEntity.ok(messageService.getMessages(matchId));
}
```

**Ошибка при отсутствии доступа:**
```json
{
  "error": "FORBIDDEN",
  "message": "You don't have access to this match"
}
```

---

### FR-MSG-04 — Метаданные сообщения 🔴 MUST

**Описание:**  
У сообщения должны храниться **отправитель** и **время создания**.

**Структура сообщения в БД:**
```sql
CREATE TABLE messages (
  id SERIAL PRIMARY KEY,
  match_id BIGINT NOT NULL,
  sender_id BIGINT NOT NULL,
  text VARCHAR(5000) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  FOREIGN KEY (match_id) REFERENCES matches(id),
  FOREIGN KEY (sender_id) REFERENCES users(id)
);
```

---

### FR-MSG-05 — Статус прочтения сообщения 🟡 SHOULD

**Описание:**  
Система может хранить признак прочтения сообщения и обновлять его при просмотре.

**Расширенная структура:**
```sql
ALTER TABLE messages ADD COLUMN is_read BOOLEAN DEFAULT FALSE;
```

**API для отметки как прочитанного:**
```http
PATCH /api/matches/{match_id}/messages/{message_id}/read
Authorization: Bearer {token}

Response 200
```

---

## 🔔 Модуль 8. Уведомления

### FR-NOTIF-01 — Создание уведомления 🟡 SHOULD

**Описание:**  
Система должна создавать уведомления о значимых событиях:
- Новое Match
- Новое сообщение в Match

**События для уведомлений:**
| Событие | Кому | Сообщение |
|---------|------|-----------|
| New Match | Обоим участникам | "You have a new match!" |
| New Message | Получателю | "Jane sent you a message" |

**Таблица в БД:**
```sql
CREATE TABLE notifications (
  id SERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL,
  type VARCHAR(50) NOT NULL,  -- MATCH_CREATED, MESSAGE_RECEIVED
  target_id BIGINT,            -- match_id или message_id
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  FOREIGN KEY (user_id) REFERENCES users(id)
);
```

---

### FR-NOTIF-02 — Получение уведомлений 🟡 SHOULD

**Описание:**  
Пользователь должен иметь возможность получить список своих уведомлений.

**API Endpoint:**
```http
GET /api/notifications?limit=20&offset=0
Authorization: Bearer {token}

Response 200:
{
  "notifications": [
    {
      "notification_id": 1,
      "type": "MATCH_CREATED",
      "target_id": 99,
      "message": "You have a new match with Jane!",
      "is_read": false,
      "created_at": "2024-01-15T10:30:00Z"
    },
    {
      "notification_id": 2,
      "type": "MESSAGE_RECEIVED",
      "target_id": 2,
      "message": "Jane sent you a message",
      "is_read": false,
      "created_at": "2024-01-15T10:35:00Z"
    }
  ],
  "total": 2
}
```

---

### FR-NOTIF-03 — Отметить уведомление как прочитанное 🟡 SHOULD

**Описание:**  
Пользователь должен иметь возможность отметить уведомление как прочитанное.

**API Endpoint:**
```http
PATCH /api/notifications/{notification_id}/read
Authorization: Bearer {token}

Response 200:
{
  "notification_id": 1,
  "is_read": true,
  "updated_at": "2024-01-15T10:40:00Z"
}
```

---

## ⚠️ Модуль 9. Ошибки и валидация

### FR-ERR-01 — Структурированные ошибки 🔴 MUST

**Описание:**  
Backend должен возвращать все ошибки в **единообразном формате**.

**Единый формат ошибок:**
```json
{
  "error": "ERROR_CODE",
  "message": "Human-readable message",
  "status": 400,
  "timestamp": "2024-01-15T10:30:00Z"
}
```

**Примеры:**
```json
// 400 Bad Request
{
  "error": "INVALID_INPUT",
  "message": "Email format is invalid",
  "status": 400
}

// 401 Unauthorized
{
  "error": "UNAUTHORIZED",
  "message": "Invalid or expired token",
  "status": 401
}

// 403 Forbidden
{
  "error": "FORBIDDEN",
  "message": "You don't have access to this resource",
  "status": 403
}

// 404 Not Found
{
  "error": "NOT_FOUND",
  "message": "User not found",
  "status": 404
}

// 500 Internal Server Error
{
  "error": "INTERNAL_ERROR",
  "message": "An unexpected error occurred",
  "status": 500
}
```

---

### FR-ERR-02 — Проверка входных данных 🔴 MUST

**Описание:**  
Некорректные входные данные должны **отклоняться** с понятным сообщением об ошибке.

**Примеры валидаций:**
```json
// Отсутствует обязательное поле
{
  "error": "MISSING_FIELD",
  "message": "Field 'email' is required",
  "field": "email"
}

// Значение вне допустимого диапазона
{
  "error": "INVALID_VALUE",
  "message": "Age must be between 18 and 100",
  "field": "age"
}

// Неверный тип данных
{
  "error": "INVALID_TYPE",
  "message": "Field 'age' must be an integer",
  "field": "age"
}
```

---

### FR-ERR-03 — Ошибка при запросе несуществующего ресурса 🔴 MUST

**Описание:**  
При запросе несуществующего объекта backend должен возвращать **404 Not Found**.

**Примеры:**
```http
GET /api/users/999999
Response 404:
{
  "error": "USER_NOT_FOUND",
  "message": "User with ID 999999 not found",
  "status": 404
}

GET /api/matches/999999/messages
Response 404:
{
  "error": "MATCH_NOT_FOUND",
  "message": "Match not found",
  "status": 404
}
```

---

### FR-ERR-04 — Запрещённый доступ 🔴 MUST

**Описание:**  
Попытка получить или изменить чужие защищённые данные должна отклоняться с **403 Forbidden**.

**Примеры:**
```http
// Попытка редактировать чужой профиль
PUT /api/profiles/42
Authorization: Bearer {token_of_user_1}

Response 403:
{
  "error": "FORBIDDEN",
  "message": "You can only edit your own profile",
  "status": 403
}

// Попытка прочитать чужие сообщения
GET /api/matches/99/messages
(где текущий пользователь не является участником)

Response 403:
{
  "error": "FORBIDDEN",
  "message": "You don't have access to this match",
  "status": 403
}
```

---

## 📍 Трассировка требований к бизнес-целям

Таблица связи функциональных требований с бизнес-требованиями системы:

| Бизнес-требование | Модуль | Связанные FR |
|---|---|---|
| **BR-01** Безопасность учётных записей | Аутентификация | FR-AUTH-01..06, FR-ERR-01,02,04 |
| **BR-02** Полнота профилей | Профиль, Интересы | FR-PROFILE-01..04, FR-INTEREST-01..04, FR-PREF-01..02 |
| **BR-03** Качество рекомендаций | Рекомендации | FR-REC-01..07, FR-ERR-01..04 |
| **BR-04** Контроль реакций | Реакции | FR-LIKE-01..03, FR-ERR-01..04 |
| **BR-05** Match и связь | Match | FR-MATCH-01..03, FR-LIKE-01..03 |
| **BR-06** Приватное общение | Сообщения | FR-MSG-01..05, FR-ERR-01..04 |
| **BR-07** Информированность | Уведомления | FR-NOTIF-01..03, FR-MSG-01 |
| **BR-08** Интеллектуальность | Рекомендации | FR-REC-03..07 |
| **BR-09** Контроль доступа | Безопасность | FR-AUTH-04, FR-MSG-03, FR-ERR-04 |
| **BR-10** Целостность данных | Все модули | FR-*, NFR-07 |

---

## 📌 Статус документа

**Документ описывает полный набор функциональных требований** проекта Nexus на момент лабораторной работы №2.

**Статистика:**
- 🔴 **MUST (MVP):** 32 требования
- 🟡 **SHOULD:** 8 требований
- 🟢 **COULD:** 1 требование

**Разработка:**
1. Все MUST требования должны быть реализованы для защиты ЛР №2
2. SHOULD требования — при наличии времени
3. COULD требования — для расширения после базовой версии

**Ответственные:**
- 🏗️ **Backend API** — Тимошенко К. Е.
- 🌐 **Frontend реализация** — Сафостюк К. С.
- 📋 **Аналитика и требования** — Ждванов П. А.