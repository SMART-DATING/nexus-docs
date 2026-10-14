# Контейнеры и границы системы

Схема показывает фактические границы исполнения. ONNX — библиотека внутри Java, не отдельный HTTP-сервис. H2 и PostgreSQL — альтернативные режимы хранения; они не используются одновременно одной конфигурацией. Vite/nginx/встроенная раздача также представляют варианты запуска.

[Описание архитектуры](../architecture/system-architecture.md) · [Запуск](../RUNBOOK.md)

![Контейнеры и границы системы](assets/architecture.svg)

[Открыть SVG](assets/architecture.svg) · [Открыть PNG](assets/architecture.png)

## Исходник Mermaid

<details>
<summary>Показать редактируемую схему</summary>

```mermaid
flowchart TB
  accTitle: Контейнерная архитектура Nexus
  accDescr: React в браузере обращается через Vite, nginx или встроенную раздачу к одному Spring Boot backend. Модель работает внутри Java, данные хранятся в PostgreSQL или H2. Голос распознаёт отдельный сервис браузера.
  U["Участник<br/>веб-приложения"]
  subgraph CLIENT["Устройство участника"]
    UI["React + TypeScript<br/>интерфейс и черновики"]
    VOICE["Голосовой ввод<br/>по отдельному действию"]
  end
  ENTRY["HTTP-вход<br/>Vite / nginx / единый JAR"]
  subgraph SERVER["Один backend-процесс · Java 21"]
    API["REST API<br/>сессия, валидация, доступ"]
    DOMAIN["Сервисы<br/>анкета, подбор, фото, чаты"]
    MODEL["Локальная RuBERT-tiny2<br/>ONNX Runtime CPU"]
    TICKETS["Разрешения на фото<br/>память процесса, 15 минут"]
  end
  DB[("PostgreSQL 16 или H2<br/>14 таблиц, тексты, фото, векторы")]
  SPEECH["Сервис распознавания браузера<br/>возможна внешняя обработка"]
  U --> UI
  UI -->|"JSON / multipart / фото"| ENTRY
  ENTRY --> API
  API --> DOMAIN
  DOMAIN -->|"сохранение истории"| MODEL
  DOMAIN --> DB
  DOMAIN --> TICKETS
  UI -.-> VOICE
  VOICE -.-> SPEECH
  SPEECH -.->|"распознанный текст"| VOICE
```

</details>
