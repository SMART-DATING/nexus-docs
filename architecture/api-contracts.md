# API-контракты Nexus (MVP)

Базовый префикс:

```text
/api/v1
```

Формат данных: JSON.

Для защищённых endpoint:

```http
Authorization: Bearer <token>
```

## 1. Единый формат ошибки

```json
{
  "timestamp": "2026-09-28T12:00:00Z",
  "status": 400,
  "code": "VALIDATION_ERROR",
  "message": "Request validation failed",
  "details": {
    "email": "Invalid email format"
  }
}
```

---

## 2. Auth

### POST /auth/register

Request:
```json
{
  "email": "user@example.com",
  "password": "StrongPassword123"
}
```

Responses:
- `201 Created`
- `400 Bad Request`
- `409 Conflict` — email уже занят.

### POST /auth/login

Request:
```json
{
  "email": "user@example.com",
  "password": "StrongPassword123"
}
```

Response `200 OK`:
```json
{
  "accessToken": "<token>",
  "tokenType": "Bearer"
}
```

Responses:
- `200 OK`
- `401 Unauthorized`

### GET /users/me
Возвращает данные текущего пользователя.

---

## 3. Profile

### GET /profiles/me
Получить собственный профиль.

### PUT /profiles/me

Request:
```json
{
  "displayName": "Alex",
  "bio": "Люблю backend, музыку и путешествия"
}
```

### GET /profiles/{userId}
Получить публичную часть профиля доступного пользователя.

---

## 4. Interest

### GET /interests
Получить справочник интересов.

### PUT /profiles/me/interests

Request:
```json
{
  "interestIds": [1, 4, 7]
}
```

Результат: актуальный набор интересов пользователя.

---

## 5. Preference

### GET /preferences/me
Получить предпочтения.

### PUT /preferences/me

Пример:
```json
{
  "minAge": 18,
  "maxAge": 30
}
```

Набор полей может уточняться после согласования предметной области.

---

## 6. Recommendation

### GET /recommendations?limit=20

Response:
```json
{
  "items": [
    {
      "userId": 42,
      "displayName": "Sam",
      "bio": "Java, кино, бег",
      "commonInterests": [
        {"id": 1, "name": "Java"},
        {"id": 5, "name": "Running"}
      ],
      "compatibilityScore": 0.82
    }
  ]
}
```

Важные правила:
- текущий пользователь исключается;
- обработанные рекомендации учитываются;
- недоступные профили не возвращаются.

---

## 7. Like / Skip

### POST /users/{userId}/like

Response:
```json
{
  "liked": true,
  "matched": true,
  "matchId": 15
}
```

Если взаимного Like нет:
```json
{
  "liked": true,
  "matched": false,
  "matchId": null
}
```

### POST /users/{userId}/skip

Response:
```json
{
  "skipped": true
}
```

Ошибки:
- `400` — попытка реакции на самого себя;
- `404` — пользователь не найден;
- `409` — реакция уже обработана.

---

## 8. Match

### GET /matches

Response:
```json
{
  "items": [
    {
      "id": 15,
      "user": {
        "id": 42,
        "displayName": "Sam"
      },
      "createdAt": "2026-09-28T09:00:00Z"
    }
  ]
}
```

### GET /matches/{matchId}
Возвращает Match только его участнику.

---

## 9. Message

### GET /matches/{matchId}/messages

Response:
```json
{
  "items": [
    {
      "id": 101,
      "senderId": 7,
      "text": "Привет!",
      "createdAt": "2026-09-28T09:10:00Z",
      "read": false
    }
  ]
}
```

### POST /matches/{matchId}/messages

Request:
```json
{
  "text": "Привет!"
}
```

Responses:
- `201 Created`
- `400 Bad Request` — пустой/слишком длинный текст;
- `403 Forbidden` — пользователь не участник Match;
- `404 Not Found` — Match отсутствует.

---

## 10. Notification

### GET /notifications

### PATCH /notifications/{notificationId}/read

Response:
```json
{
  "id": 55,
  "read": true
}
```

---

## 11. HTTP-статусы

| Статус | Значение |
|---|---|
| 200 | Успешное чтение/изменение |
| 201 | Ресурс создан |
| 204 | Успешно, тела ответа нет |
| 400 | Ошибка входных данных |
| 401 | Не авторизован |
| 403 | Нет прав |
| 404 | Ресурс не найден |
| 409 | Конфликт состояния/дубликат |
| 500 | Необработанная серверная ошибка |

## 12. Что вынести в Swagger

После появления backend endpoints этот документ следует синхронизировать с
OpenAPI/Swagger. Источником истины по техническому контракту в коде должен стать
OpenAPI, а этот Markdown — понятным описанием решений для защиты.
