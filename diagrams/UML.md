# Основные классы
```mermaid
classDiagram
  ApiController --> NexusService
  SecurityConfig --> NexusService : identify
  NexusService --> UserAccountRepository
  NexusService --> InterestRepository
  NexusService --> UserInterestRepository
  NexusService --> PreferenceRepository
  NexusService --> ProfilePropertyRepository
  NexusService --> ReactionRepository
  NexusService --> PairMatchRepository
  NexusService --> ChatMessageRepository
  NexusService --> NoticeRepository
  NexusService --> SessionTokenRepository
  class NexusService {
    authenticate(credentials, register)
    identify(header)
    saveProfile(userId, profile)
    recommend(userId, limit)
    react(actorId, targetId, like)
    match(userId, matchId)
    send(userId, matchId, text)
  }
```
DTO Requests отделяет входные данные от JPA-сущностей. Публичный профиль проецируется сервисом с учётом visible. Общий транзакционный сервис выбран для небольшого прототипа; выделение Auth/Profile/Recommendation/Chat сервисов — направление развития.
