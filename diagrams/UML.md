# UML текущего прототипа

```mermaid
classDiagram
 ApiController --> NexusService
 ApiController --> ContextService
 ApiController --> GalleryService
 NexusService --> ContextService
 NexusService --> GalleryService
 ContextService --> SemanticEncoder
 ContextService --> PrivateContextRepository
 GalleryService --> ProfilePhotoRepository
 GalleryService --> AvatarImages
 NexusService --> UserAccountRepository
 NexusService --> ReactionRepository
 NexusService --> PairMatchRepository
 NexusService --> ChatMessageRepository
 class SemanticEncoder {
  encode(text) double[]
  tokenize(text) List
  cosine(a,b) double
 }
 class ContextService {
  mine(userId)
  save(userId,id,title,content)
  delete(userId,id)
  vector(userId) double[]
 }
 class GalleryService {
  view(targetId,viewerId)
  image(photoId,access)
  add(userId,file)
  replace(userId,photoId,file)
  delete(userId,photoId)
  reorder(userId,ids)
 }
```

Сущности и связи показаны в ERD.md. На клиенте App управляет маршрутом/сессией, ContextEditor — собственными рассказами, PhotoUpload — галереей владельца, PhotoGallery — только разрешёнными кадрами кандидата, SwipeDeck — жестом и состоянием реакции. api.ts добавляет Bearer к JSON/multipart-запросам; браузер загружает изображения по временным access-URL без сессионного токена в адресе.
