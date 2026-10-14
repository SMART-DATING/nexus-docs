# Связь целей, сценариев и реализации

Матрица показывает, почему существует функция, каким сценарием она используется и где проверяется. Она связывает продуктовые цели с технической приёмкой; автоматические тесты не доказывают бизнес-эффект.

| Цель | Сценарии | Требования | Основная реализация | Свидетельство проверки |
| --- | --- | --- | --- | --- |
| BR-01 · основания знакомства | UC-03, UC-05 | FR-05, FR-06, FR-14–FR-17 | `NexusService`, `ContextService`, `SemanticEncoder` | `ApiIntegrationTest`: city/ranking/gender/cycle; `SemanticEncoderTest` |
| BR-02 · лёгкий первый рассказ | UC-01–UC-03 | FR-01, FR-03, FR-07–FR-09 | `Onboarding`, `GuidedInterview`, `MatchingSetup`, `ContextEditor` | Компонентные тесты этих экранов; API validation/context tests |
| BR-03 · контроль раскрытия | UC-03, UC-04, UC-08 | FR-04, FR-10–FR-13, FR-25 | `GalleryService`, `ContextService`, `PhotoUpload`, `DataControls` | API privacy, photo quota, hidden profile; frontend photo/media tests |
| BR-04 · взаимное общение | UC-05, UC-06 | FR-18, FR-20–FR-22, FR-24 | `NexusService.react/send/readMessages`, `SwipeDeck`, экран чата | Concurrent likes, access boundaries, unread tests; HTTP smoke |
| BR-05 · понятный следующий шаг | UC-01, UC-02, UC-05, UC-07 | FR-03, FR-19, FR-23, FR-28 | `WelcomeSetup`, `AppNavigation`, `SwipeDeck`, `ChatMenu` | WelcomeSetup, SwipeWaiting, App, ChatMenu, PublicHome tests; ручной путь |
| BR-06 · управление участием | UC-07–UC-10 | FR-23, FR-25–FR-27 | `BlockService`, `DataExportService`, `ChatPreference` | API block, export, chat controls; ChatControls tests |

## Где находятся проверки

- Backend: [src/test/java/ru/nexus](https://github.com/SMART-DATING/nexus-backend/tree/main/src/test/java/ru/nexus). `PostgresIntegrationTest` наследует те же сценарии API и включается переменными `TEST_POSTGRES_*`.
- Frontend: тесты `*.test.ts` / `*.test.tsx` рядом с компонентами в [src](https://github.com/SMART-DATING/nexus-frontend/tree/main/src).
- Сквозной HTTP-путь: [scripts/smoke.mjs](https://github.com/SMART-DATING/nexus-frontend/blob/main/scripts/smoke.mjs).
- Команды, ручная приёмка и ограничения доказательств: [TESTING.md](../TESTING.md).

## Правила изменений

Новое требование получает отдельный ID. Если меняется действующее поведение, обновляются его критерий приёмки, связанный сценарий, контракт и проверки. Предложения сначала фиксируются в [roadmap](../roadmap.md), а в требования текущей версии попадают после реализации. Для BR-01/02/05 дополнительно требуется пользовательское исследование: одни технические проверки не подтверждают удобство и релевантность.
