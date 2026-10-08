# Запуск Nexus

## Исходники
```sh
git clone --branch feature/working-prototype https://github.com/SMART-DATING/nexus-backend.git
git clone --branch feature/working-prototype https://github.com/SMART-DATING/nexus-frontend.git
git clone --branch feature/working-prototype https://github.com/SMART-DATING/nexus-docs.git
```
Каталоги должны быть соседними. До слияния используйте рабочую ветку во всех репозиториях.

## Самый простой общий запуск
Docker Engine/Desktop с Linux-контейнерами, из nexus-frontend:
```sh
docker compose up --build --wait
```
Открыть http://127.0.0.1:8088. База PostgreSQL сохраняется в named volume. `docker compose down` останавливает сервисы; для обычной остановки не добавляйте -v. Логи: `docker compose logs backend`.

## Локальная разработка с H2
Java 21+, Node.js 22.12+. Терминал backend:
```sh
./mvnw clean package
java -jar target/nexus-backend-0.0.1-SNAPSHOT.jar --spring.profiles.active=local --nexus.demo=true
```
На Windows используйте `.\mvnw.cmd`. Терминал frontend:
```sh
npm ci
npm run dev
```
Открыть http://127.0.0.1:5173; health — http://127.0.0.1:8080/api/v1/health. В H2 не нужно «включать базу»: она открывается вместе с Java-приложением. Файлы находятся в backend/data. Нельзя одновременно использовать один файл из двух процессов. Остановка — Ctrl+C.

## Только PostgreSQL для IDE
В backend: `docker compose up -d postgres`. Запустить `ru.nexus.NexusApplication` на JDK 21 с профилем postgres, либо JAR с `--spring.profiles.active=postgres`. По умолчанию jdbc:postgresql://127.0.0.1:5432/nexus, nexus / nexus-local-dev.

## H2 в Docker
В backend: `docker compose -f compose.h2.yaml up --build --wait`; API на 8080. Этот режим не нужен, если выбрана PostgreSQL. Собственный named volume хранит данные H2.

## Единый JAR с интерфейсом
В docs есть build-demo.ps1 для Windows и build-demo.sh для Linux. Они собирают frontend и включают dist в backend JAR. После сборки запустить JAR и открыть 8080. Готовый комплект START.cmd + nexus-demo.jar не требует Maven, npm или Docker; требуется Java 21.

## Демонстрация
Пароль всех 14 вымышленных аккаунтов — `NexusDemo2026!`: demo@nexus.local (Алекс), demo1@nexus.local (Саша), demo2–demo13@nexus.local. Инициализация включается NEXUS_DEMO=true или --nexus.demo=true; полный Compose включает её.

1. Открыть demo в первой вкладке, demo1 во второй. Вкладки используют отдельные sessionStorage.
2. В первой поставить like Саше, во второй — Алексу.
3. В «Совпадениях» открыть чат, отправить сообщение. Обновление каждые 2 секунды.
4. Прочитать уведомление; оно открывает соответствующий чат.
5. В третьем аккаунте открыть URL чужого match: сервер откажет в доступе.
6. Зарегистрировать ещё один аккаунт, заполнить профиль, скрыть bio, проверить сохранение и публичную проекцию.

Реакции сохраняются. Для повторного чистого сценария регистрируйте новые тестовые аккаунты. Smoke-сценарий в frontend создаёт два таких аккаунта автоматически.

## Проверки ошибок
Проверьте Java 21, правильную ветку и профиль БД. Если health не отвечает, смотрите лог backend. Если health на 8080 работает, а через 5173 нет — проверьте адрес proxy и перезапустите Vite. Строгий порт предотвращает незаметный переход на 5174. В Docker nginx обращается к backend:8080; localhost внутри контейнера — сам контейнер.
