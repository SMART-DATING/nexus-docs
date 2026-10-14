# UML основных сервисов

Диаграмма показывает выбранный срез зависимостей backend, а не исчерпывающую сигнатуру каждого класса. CoreRepositories — группа существующих репозиториев, не класс исходников. Зависимости экспорта от репозиториев и часть служебных связей опущены для читаемости. Названия показанных методов сверены с кодом.

Клиентские компоненты и их ответственность перечислены в [README frontend](https://github.com/SMART-DATING/nexus-frontend#структура-клиента). Сущности и кардинальности вынесены в [ERD](ERD.md).

[Сервисы backend](https://github.com/SMART-DATING/nexus-backend/tree/main/src/main/java/ru/nexus/service) · [Архитектура](../architecture/system-architecture.md)

![UML основных сервисов](assets/UML.svg)

[Открыть SVG](assets/UML.svg) · [Открыть PNG](assets/UML.png)

## Исходник Mermaid

<details>
<summary>Показать редактируемую схему</summary>

```mermaid
classDiagram
  accTitle: UML основных сервисов Nexus
  accDescr: ApiController вызывает NexusService и специализированные сервисы. Репозитории и локальный SemanticEncoder выделены отдельными зависимостями. Показан выбранный срез, не все поля классов.
  direction LR
  ApiController --> NexusService
  ApiController --> ContextService
  ApiController --> GalleryService
  ApiController --> BlockService
  ApiController --> DataExportService
  NexusService --> ContextService
  NexusService --> GalleryService
  NexusService --> BlockService
  NexusService --> PresenceService
  NexusService --> CoreRepositories
  ContextService --> SemanticEncoder
  ContextService --> PrivateContextRepository
  GalleryService --> BlockService
  GalleryService --> ProfilePhotoRepository
  GalleryService --> AvatarImages
  DataExportService --> NexusService
  DataExportService --> ContextService
  DataExportService --> BlockService
  BlockService --> UserBlockRepository
  PresenceService --> UserAccountRepository
  class CoreRepositories {
    <<group>>
    UserAccountRepository
    ProfilePropertyRepository
    ReactionRepository
    PairMatchRepository
    ChatMessageRepository
    ChatPreferenceRepository
    SessionTokenRepository
    NoticeRepository
    InterestRepository
    UserInterestRepository
    PreferenceRepository
  }
  class NexusService {
    authenticate(credentials, register)
    profileFor(id, viewer)
    recommend(id, limit)
    react(actor, target, like)
    send(id, matchId, text)
    readMessages(id, matchId, throughId)
    chatAction(id, matchId, action)
  }
  class ContextService {
    mine(userId)
    save(userId, contextId, title, content)
    delete(userId, id)
    vector(userId)
  }
  class SemanticEncoder {
    available() boolean
    encode(text) double[]
    tokenize(text) List
    cosine(a, b) double
  }
  class GalleryService {
    view(target, viewer)
    eligibleViews(targetIds, viewer)
    image(photoId, access)
    add(userId, file)
    replace(userId, photoId, file)
    delete(userId, photoId)
    reorder(userId, ids)
  }
```

</details>
