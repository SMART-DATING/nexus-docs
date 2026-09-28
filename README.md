# Nexus — Документация к лабораторной работе №2

**Nexus** — клиент-серверное веб-приложение для подбора пользователей на основе интересов, предпочтений и истории взаимодействий.

Этот каталог содержит проектную документацию, необходимую для второго чекпоинта: анализ бизнес-требований, функциональные и нефункциональные требования, варианты использования, архитектуру, API-контракты, ERD, роли, workflow и roadmap.

---

## 📂 Структура каталога

```text
nexus-docs/
├── 📄 README.md                      # Главная страница документации
├── 📋 LAB2_CHECKLIST.md              # Чеклист критериев лабораторной работы №2
│
├── 🎯 requirements/                  # Требования к системе
│   ├── business-requirements.md      # Анализ бизнес-требований и целей
│   ├── functional-requirements.md    # Функциональные требования
│   ├── non-functional-requirements.md# Нефункциональные требования (SLA, нагрузка, безопасность)
│   └── use-cases.md                  # Варианты использования (Use Cases)
│
├── 🏗️ architecture/                  # Архитектура и спецификации
│   ├── system-architecture.md        # Описание системной архитектуры и компонентов
│   └── api-contracts.md              # Спецификация REST API / контракты
│
├── 📊 diagrams/                      # Диаграммы и схемы
│   └── ERD.md                        # ER-диаграмма базы данных (Entity-Relationship)
│
├── 👥 team/                          # Организация работы команды
│   ├── roles.md                      # Распределение ролей и зон ответственности
│   └── workflow.md                   # Регламент разработки, GitFlow и Code Review
│
└── 🗺️ roadmap.md                     # Дорожная карта и этапы реализации
```

---

## 🛠 Технологический стек

### Frontend
- **Framework / Library:** React
- **Language:** TypeScript
- **Build Tool:** Vite

### Backend
- **Language:** Java
- **Framework:** Spring Boot
- **ORM / Data Access:** Spring Data JPA / Hibernate
- **Security:** Spring Security

### Database
- PostgreSQL

---

## 📌 Статус проекта

Документация описывает **целевое состояние** проекта на момент сдачи лабораторной работы №2. Фактически реализованные функции и текущий прогресс отслеживаются в **Issues / Project Board** и в `README` соответствующих репозиториев (Backend / Frontend).