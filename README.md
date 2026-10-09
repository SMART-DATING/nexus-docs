# Nexus

Nexus помогает знакомиться по общим интересам и взглядам. Пользователь рассказывает о себе в закрытом пространстве, получает подборку по смысловой близости и начинает общение после взаимной симпатии.

## Продукт

Короткое знакомство через темы и наводящие вопросы; текстовый или голосовой ответ с редактированием перед сохранением. До шести фотографий с взаимным раскрытием. Локальная NLP-модель, свайпы, повтор пропущенных анкет, взаимные совпадения, чат и уведомления.

## Документация

- [Запуск](RUNBOOK.md) и [проверки](TESTING.md)
- [Продуктовые цели](requirements/business-requirements.md)
- [Функциональные требования](requirements/functional-requirements.md), [ограничения](requirements/non-functional-requirements.md), [сценарии](requirements/use-cases.md)
- [Архитектура](architecture/system-architecture.md), [API](architecture/api-contracts.md), [модель](architecture/MODEL.md)
- [Первое знакомство и голос](design/onboarding.md)
- [Telegram: варианты интеграции](architecture/telegram.md)
- [ERD](diagrams/ERD.md), [UML](diagrams/UML.md)
- [История изменений](changelog.md) и [план развития](roadmap.md)

## Репозитории

| Репозиторий | Назначение |
| --- | --- |
| [nexus-backend](https://github.com/SMART-DATING/nexus-backend) | Java / Spring Boot API, хранение данных, NLP |
| [nexus-frontend](https://github.com/SMART-DATING/nexus-frontend) | React / TypeScript приложение |
| [nexus-docs](https://github.com/SMART-DATING/nexus-docs) | Продукт, архитектура и эксплуатация |

Текущая разработка ведётся в `feature/working-prototype`. Публичный запуск пока не подготовлен: необходимые работы перечислены в roadmap. Исходные материалы и прежние решения сохранены в `archive/`.
