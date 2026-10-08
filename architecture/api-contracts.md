# REST API прототипа

Префикс `/api/v1`, JSON UTF-8. Для всех методов, кроме health/register/login, заголовок `Authorization: Bearer <accessToken>` обязателен. Ошибки: `{ "status": 400, "message": "..." }`; обработчик валидации также добавляет timestamp. Клиент должен опираться на status/message.

## Авторизация
- `GET /health` → `{ "status": "ok" }`.
- `POST /auth/register` → 201; `POST /auth/login` → 200. Тело: `{ "email":"a@example.com", "password":"Password123!" }`.
- Ответ обоих: `{ "accessToken":"...", "tokenType":"Bearer", "expiresAt":"ISO-8601", "user": { "id":1, "email":"a@example.com", "profile":{...}, "preferences":{"minAge":18,"maxAge":60} } }`.
- Токен непрозрачный (не JWT), живёт 24 часа.
- `POST /auth/logout` → 204; токен отзывается.
- `GET /users/me` → объект user.

## Профиль, интересы, предпочтения
- `GET /profiles/me` → профиль со всеми собственными свойствами.
- `GET /profiles/{userId}` → публичный профиль; для собственного ID включает скрытые поля.
- `PUT /profiles/me` → сохранённый профиль; тело полностью заменяет четыре свойства и набор интересов:
```json
{
  "properties": [
    {"name":"display_name","value":"Алекс","visible":true},
    {"name":"bio","value":"Люблю музыку","visible":true},
    {"name":"birth_date","value":"2001-04-12","visible":false},
    {"name":"city","value":"Москва","visible":true}
  ],
  "interests":["Музыка","Кофе"]
}
```
- Профиль ответа: `{ "userId":1, "properties":[...], "interests":[...] }`. Чужие скрытые поля отсутствуют полностью. Необязательное поле avatarUrl содержит локальный путь, например /avatars/demo-01.svg; загрузка пользовательских изображений пока не реализована.
- `GET /interests` → `{ "items": ["Музыка", "Кино", ...] }`. Числовых interestIds в этом прототипе нет. Отдельный PUT interests заменён атомарным сохранением профиля.
- `GET /preferences/me`, `PUT /preferences/me` → `{ "minAge":18, "maxAge":60 }`; PUT принимает ту же структуру.

## Подбор и реакции
- `GET /recommendations?limit=20` → `{ "items":[{...profile, "commonInterests":["Кофе"], "compatibilityScore":0.5}], "skippedCount":2 }`.
- limit ограничивается диапазоном 1–50. Сортировка score ↓, userId ↑. Неполный профиль — 409, пустая выдача — 200.
- `POST /users/{userId}/like`, `POST /users/{userId}/skip` → `{ "liked":true, "skipped":false, "matched":true, "matchId":15 }`. При отсутствии match `matchId:null`.
- Повторная реакция — 409, self — 400, неизвестный user — 404. Тела запросов не нужны.

- `POST /recommendations/restart` → `{ "restored":2 }`. Bearer обязателен, тело не нужно. Удаляются только Skip запрашивающего пользователя; Like, совпадения, сообщения и чужие реакции сохраняются. Повтор без новых Skip возвращает 0. Возрастной фильтр применяется к повторной выдаче как обычно.

## Match и чат
- `GET /matches` → `{ "items":[{ "id":15, "user":{...publicProfile}, "createdAt":"ISO-8601" }] }`.
- `GET /matches/{matchId}` → один элемент. Дополнительный alias `GET /match/{matchId}` поддерживает обозначение преподавателя.
- Маршрут страницы frontend: `/match/{matchId}`. Разделы: `/`, `/#matches`, `/#profile`, `/#notifications`. Навигация синхронизирует адрес и экран, включая обновление и историю браузера.
- `GET /matches/{matchId}/messages?after=0` → `{ "items":[{ "id":1, "matchId":15, "senderId":1, "text":"Привет", "createdAt":"ISO-8601" }] }`.
- Возвращаются первые 100 сообщений с id > after, в порядке ID. Для следующей порции передайте последний ID. Для опроса новых — тот же курсор.
- `POST /matches/{matchId}/messages`, тело `{ "text":"Привет" }` → 201, объект сообщения. От 1 непустого до 5000 символов; внешние пробелы удаляются.
- Только участникам: 403 для постороннего, 404 при отсутствии match.

## Уведомления
- `GET /notifications` → `{ "items":[{ "id":1, "userId":1, "matchId":15, "text":"...", "seen":false, "createdAt":"ISO-8601" }] }`, последние 100 по ID ↓.
- `PATCH /notifications/{id}/read` → объект с `seen:true`, идемпотентно; чужой ID — 403.

Статусы: 200/201/204 — успех; 400 — данные; 401 — сессия/вход; 403 — чужой ресурс; 404 — отсутствие; 409 — дубликат/незавершённый профиль. Необработанные ошибки могут вернуть стандартный ответ Spring, детали исключений не раскрываются.
