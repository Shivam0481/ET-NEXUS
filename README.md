# 🏦 ET AI Financial Concierge

> An AI-powered conversational concierge that helps users discover and navigate the complete **Economic Times** ecosystem — ET Prime, Markets, Masterclasses, Events, and Financial Services — through a single, intelligent chat interface.

---

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [System Architecture](#system-architecture)
  - [Architecture Diagram](#architecture-diagram)
  - [Layer Breakdown](#layer-breakdown)
- [Tech Stack](#tech-stack)
- [API Design](#api-design)
- [Database Schema](#database-schema)
  - [Schema Overview](#schema-overview)
  - [Entity-Relationship Diagram](#entity-relationship-diagram)
  - [Table Reference](#table-reference)
- [RAG Pipeline](#rag-pipeline)
- [User Profiling Flow](#user-profiling-flow)
- [Directory Structure](#directory-structure)
- [Getting Started](#getting-started)
- [Environment Variables](#environment-variables)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

The **ET AI Financial Concierge** is a multi-layered intelligent system that acts as a single entry point to the entire Economic Times product suite. Instead of requiring users to navigate dozens of disconnected pages, the concierge:

1. **Profiles users conversationally** — determining financial goals, risk appetite, investment horizon, and knowledge level within a single chat session.
2. **Understands intent in real time** — whether someone is exploring content, evaluating an investment product, or looking for an upcoming masterclass.
3. **Delivers personalized, explainable recommendations** — every suggestion comes with reasoning mapped to the user's profile, powered by a Retrieval-Augmented Generation (RAG) pipeline.

---

## Key Features

| Feature | Description |
|---|---|
| **Conversational Profiling** | Progressively builds a financial profile through natural dialogue (income, goals, risk, experience). |
| **Unified Discovery** | Surfaces relevant ET Prime articles, market insights, masterclasses, events, and partner financial products from one interface. |
| **RAG-Powered Responses** | Combines user context + behavioral signals + semantic content retrieval before prompting the LLM for grounded, accurate answers. |
| **Explainable Recommendations** | Every recommendation includes a human-readable explanation of *why* it was suggested, with confidence scoring. |
| **Behavioral Tracking** | Logs granular user events (reads, clicks, enrollments) to continuously refine personalization. |
| **Multi-Platform** | Flutter-based frontend delivers a native-quality experience on iOS, Android, and Web from a single codebase. |
| **Session Continuity** | Redis-backed session management ensures conversation context persists across reconnects. |

---

## System Architecture

### Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────────┐
│                        FRONTEND LAYER                                │
│                    Flutter App (iOS / Android / Web)                  │
│  ┌──────────┐  ┌──────────────┐  ┌───────────┐  ┌──────────────┐   │
│  │ Chat UI  │  │ Profile View │  │ Discovery │  │ Rec. Cards   │   │
│  └────┬─────┘  └──────┬───────┘  └─────┬─────┘  └──────┬───────┘   │
│       │               │                │               │            │
└───────┼───────────────┼────────────────┼───────────────┼────────────┘
        │               │                │               │
        ▼               ▼                ▼               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                     API GATEWAY / BACKEND LAYER                      │
│                         FastAPI (Python)                              │
│  ┌──────────┐  ┌──────────┐  ┌───────────┐  ┌──────────────────┐   │
│  │ /chat    │  │ /user    │  │ /event    │  │ /recommend       │   │
│  └────┬─────┘  └────┬─────┘  └─────┬─────┘  └────────┬─────────┘   │
│       │              │              │                  │             │
└───────┼──────────────┼──────────────┼──────────────────┼─────────────┘
        │              │              │                  │
        ▼              ▼              ▼                  ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    AI ORCHESTRATION LAYER                             │
│  ┌────────────────┐  ┌──────────────┐  ┌──────────────────────┐     │
│  │ LLM Engine     │  │ Prompt Mgr   │  │ RAG Pipeline         │     │
│  │ (GPT-4 / etc.) │  │ (Templates)  │  │ (Retrieve → Rank     │     │
│  │                │  │              │  │  → Augment → Gen.)   │     │
│  └────────┬───────┘  └──────┬───────┘  └──────────┬───────────┘     │
│           │                 │                      │                 │
└───────────┼─────────────────┼──────────────────────┼─────────────────┘
            │                 │                      │
            ▼                 ▼                      ▼
┌──────────────────────────────────────────────────────────────────────┐
│                         DATA LAYER                                   │
│  ┌────────────────┐  ┌──────────────────┐  ┌──────────────────┐     │
│  │ PostgreSQL     │  │ Vector DB        │  │ Redis            │     │
│  │ (Users, Recs,  │  │ (Pinecone/FAISS/ │  │ (Sessions,       │     │
│  │  Products,     │  │  pgvector)       │  │  Cache, Rate     │     │
│  │  Events, etc.) │  │                  │  │  Limiting)       │     │
│  └────────────────┘  └──────────────────┘  └──────────────────┘     │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
            │                 │                      │
            ▼                 ▼                      ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    EXTERNAL SERVICES LAYER                           │
│  ┌────────────────┐  ┌──────────────────┐  ┌──────────────────┐     │
│  │ ET APIs        │  │ Financial Partner │  │ Market Data      │     │
│  │ (Prime, Mkts,  │  │ APIs (MF, Ins.,  │  │ Feeds (NSE/BSE)  │     │
│  │  Events)       │  │  Loans, etc.)    │  │                  │     │
│  └────────────────┘  └──────────────────┘  └──────────────────┘     │
└──────────────────────────────────────────────────────────────────────┘
```

### Layer Breakdown

| # | Layer | Responsibility | Key Technologies |
|---|---|---|---|
| 1 | **Frontend** | Chat-driven conversational UI, profile dashboards, recommendation cards, discovery screens | Flutter, Dart, Riverpod / Bloc |
| 2 | **API Gateway / Backend** | REST endpoints, request validation, auth middleware, rate limiting, response formatting | FastAPI, Pydantic, Python 3.11+ |
| 3 | **AI Orchestration** | Prompt assembly, RAG retrieval, LLM invocation, intent classification, entity extraction | LangChain / LlamaIndex, OpenAI API, custom prompt templates |
| 4 | **Data** | Persistent storage (structured + vector), session/cache management | PostgreSQL 15+ (pgvector), Pinecone / FAISS, Redis 7+ |
| 5 | **External Services** | Real-time market data, ET content feeds, financial partner product catalogs | ET internal APIs, NSE/BSE data feeds, partner REST APIs |

---

## Tech Stack

| Component | Technology | Purpose |
|---|---|---|
| Mobile & Web UI | **Flutter 3.x** (Dart) | Cross-platform chat interface |
| Backend API | **FastAPI** (Python 3.11+) | High-performance async API server |
| LLM | **GPT-4 Turbo** / Azure OpenAI | Conversational intelligence |
| Embeddings | **text-embedding-ada-002** (or equivalent) | Semantic vector representations |
| Vector Store | **pgvector** (primary) / Pinecone (scale) | Nearest-neighbor retrieval for RAG |
| Relational DB | **PostgreSQL 15+** | Structured data persistence |
| Cache & Sessions | **Redis 7+** | Low-latency session store, caching layer |
| Orchestration | **LangChain** / custom pipeline | RAG pipeline, prompt management, tool use |
| Auth | **JWT + OAuth 2.0** | Secure stateless authentication |
| Deployment | **Docker**, **Kubernetes** | Containerized, scalable deployment |
| Monitoring | **Prometheus + Grafana** | Metrics, alerting, dashboards |

---

## API Design

### Core Endpoints

#### `/chat` — Conversational Interface

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/v1/chat/message` | Send a user message; receive AI response + any recommendations |
| `GET` | `/api/v1/chat/conversations` | List user's conversation history |
| `GET` | `/api/v1/chat/conversations/{id}` | Retrieve full conversation with messages |
| `DELETE` | `/api/v1/chat/conversations/{id}` | Archive a conversation |

**Request — `POST /api/v1/chat/message`**
```json
{
  "conversation_id": "uuid | null (creates new)",
  "message": "I want to start investing ₹10,000/month for retirement",
  "context": {
    "screen": "home",
    "device": "android"
  }
}
```

**Response**
```json
{
  "conversation_id": "c9f2a1...",
  "message": {
    "id": "msg_abc...",
    "role": "assistant",
    "content": "Great goal! To recommend the right retirement plan, I'd like to understand a couple of things...",
    "intent": "investment_query",
    "entities": [{"type": "amount", "value": 10000}, {"type": "goal", "value": "retirement"}]
  },
  "recommendations": [],
  "profiling_stage": "goals"
}
```

---

#### `/user` — User Profile & Insights

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/v1/user/register` | Create a new user account |
| `POST` | `/api/v1/user/login` | Authenticate and receive JWT |
| `GET` | `/api/v1/user/profile` | Get user profile + financial insights |
| `PATCH` | `/api/v1/user/profile` | Update user profile |
| `GET` | `/api/v1/user/insights` | Get AI-derived financial profile |

---

#### `/event` — Behavioral Event Tracking

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/v1/event/track` | Log a user behavior event |
| `POST` | `/api/v1/event/batch` | Log multiple events in batch |
| `GET` | `/api/v1/event/history` | Retrieve event history (paginated) |

**Request — `POST /api/v1/event/track`**
```json
{
  "event_type": "article_read",
  "entity_type": "content",
  "entity_id": "content_uuid_here",
  "event_data": {
    "read_duration_sec": 180,
    "scroll_depth_pct": 92
  }
}
```

---

#### `/recommend` — Personalized Recommendations

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/v1/recommend/feed` | Get personalized recommendation feed |
| `GET` | `/api/v1/recommend/{id}` | Get detailed recommendation with explanation |
| `POST` | `/api/v1/recommend/{id}/feedback` | Submit rating/feedback on a recommendation |
| `GET` | `/api/v1/recommend/products` | Get product recommendations filtered by category |

**Response — `GET /api/v1/recommend/feed`**
```json
{
  "recommendations": [
    {
      "id": "rec_001...",
      "type": "product",
      "title": "SBI Bluechip Fund — Direct Growth",
      "explanation": "This large-cap mutual fund aligns with your moderate risk appetite and long-term retirement goal. Its 5-year CAGR of 14.2% and low expense ratio make it suitable for your ₹10,000/month SIP plan.",
      "confidence": 0.89,
      "relevance_factors": ["risk_aligned", "goal_match:retirement", "horizon_match:long_term"],
      "entity_type": "product",
      "entity_id": "prod_sbi_blue..."
    }
  ],
  "total": 12,
  "page": 1
}
```

---

## Database Schema

### Schema Overview

The schema file ([`schema.sql`](./schema.sql)) defines **13 tables** organized into four functional groups:

```
┌─────────────┐     ┌──────────────┐     ┌──────────────────┐
│   users      │────▶│ user_insights │     │ prompt_templates │
│              │     │ (1:1)        │     │                  │
│              │     └──────────────┘     └──────────────────┘
│              │
│              │────▶┌──────────────┐     ┌──────────────────┐
│              │     │ user_events   │     │ products         │
│              │     │ (1:N)        │     │                  │
│              │     └──────────────┘     └──────────────────┘
│              │
│              │────▶┌──────────────┐     ┌──────────────────┐
│              │     │conversations │────▶│ messages         │
│              │     │ (1:N)        │     │ (1:N)            │
│              │     └──────────────┘     └──────────────────┘
│              │
│              │────▶┌──────────────┐     ┌──────────────────┐
│              │     │recommendations│     │ content          │
│              │     │ (1:N)        │────▶│ content_chunks   │
│              │     └──────────────┘     │ (1:N)            │
│              │                          └──────────────────┘
│              │────▶┌──────────────┐
│              │     │ sessions     │     ┌──────────────────┐
│              │     │ (1:N)        │     │ audit_log        │
│              │     └──────────────┘     │                  │
│              │────▶┌──────────────┐     └──────────────────┘
│              │     │ feedback     │
│              │     │ (1:N)        │
└─────────────┘     └──────────────┘
```

### Table Reference

| # | Table | Description | Key Columns |
|---|---|---|---|
| 1 | `users` | Core user identity and authentication | `email`, `auth_provider`, `et_prime_member` |
| 2 | `user_insights` | AI-derived financial profile (1:1 with user) | `risk_appetite`, `financial_goals`, `confidence_scores` |
| 3 | `user_events` | Behavioral event stream | `event_type`, `entity_type`, `event_data` |
| 4 | `products` | ET services & financial partner offerings | `category`, `risk_category`, `suitability`, `pricing` |
| 5 | `content` | Articles, courses, reports with **vector embeddings** | `content_type`, `source`, `embedding` (1536-dim) |
| 6 | `content_chunks` | Chunked content for granular RAG retrieval | `chunk_text`, `embedding`, `chunk_index` |
| 7 | `recommendations` | Personalized AI-generated recommendations | `explanation`, `confidence_score`, `relevance_factors` |
| 8 | `conversations` | Chat sessions | `profiling_stage`, `intent_tags`, `summary` |
| 9 | `messages` | Individual chat messages | `role`, `content`, `intent`, `entities`, `tool_calls` |
| 10 | `sessions` | Application sessions for analytics | `device_info`, `ip_address` |
| 11 | `feedback` | Explicit user feedback | `rating`, `category`, `comment` |
| 12 | `prompt_templates` | Versioned prompt templates for AI layer | `template`, `version`, `variables` |
| 13 | `audit_log` | Immutable compliance & debugging log | `action`, `resource_type`, `details` |

### Key Design Decisions

- **pgvector for embeddings**: Content and content_chunks store `vector(1536)` columns with IVFFlat indexes, enabling semantic search directly in PostgreSQL without a separate vector DB for initial scale.
- **JSONB for flexible fields**: Financial goals, portfolio details, pricing, and metadata use JSONB to accommodate varying shapes without schema migrations.
- **Confidence scoring**: `user_insights.confidence_scores` tracks how certain the AI is about each profiled attribute, guiding follow-up questions.
- **Explainability by design**: `recommendations.explanation` and `relevance_factors` ensure every suggestion is traceable.

---

## RAG Pipeline

The Retrieval-Augmented Generation pipeline ensures responses are grounded in real ET content rather than hallucinated.

```
User Message
     │
     ▼
┌─────────────────────┐
│ 1. INTENT DETECTION  │  ← Classify: investment_query | content_discovery
│    & ENTITY EXTRACT  │     event_search | general_chat | profiling
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ 2. CONTEXT ASSEMBLY  │  ← Pull from Redis session + user_insights +
│                      │     recent conversation history + user_events
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ 3. SEMANTIC SEARCH   │  ← Embed query → search content_chunks via
│    (RETRIEVAL)       │     pgvector cosine similarity → top-K results
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ 4. RE-RANKING        │  ← Score retrieved chunks against user profile,
│                      │     recency, relevance, and diversity
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ 5. PROMPT ASSEMBLY   │  ← Merge: system prompt + user profile context +
│                      │     retrieved content + conversation history +
│                      │     product catalog (if relevant)
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ 6. LLM GENERATION    │  ← GPT-4 Turbo generates response with
│                      │     citations, recommendations, and explanations
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ 7. POST-PROCESSING   │  ← Extract recommendations → store in DB
│                      │     Log token usage → update conversation summary
│                      │     Update user_insights if new info detected
└─────────────────────┘
```

### RAG Context Window Strategy

| Source | Tokens (approx.) | Purpose |
|---|---|---|
| System prompt + template | ~500 | Persona, rules, output format |
| User profile (insights) | ~300 | Personalization context |
| Conversation history (last 10 msgs) | ~1,500 | Continuity |
| Retrieved content chunks (top 5) | ~2,000 | Grounded knowledge |
| Product catalog (filtered) | ~500 | Recommendation candidates |
| **Total context** | **~4,800** | Fits well within 128K window |

---

## User Profiling Flow

The concierge progressively profiles users across **five stages** within a natural conversation:

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌───────────┐     ┌──────────┐
│  INTRO  │────▶│  GOALS  │────▶│  RISK   │────▶│ PORTFOLIO │────▶│ COMPLETE │
│         │     │         │     │         │     │           │     │          │
│ Name,   │     │ What do │     │ How do  │     │ Current   │     │ Profile  │
│ context │     │ you want│     │ you feel│     │ holdings, │     │ ready —  │
│         │     │ to      │     │ about   │     │ experience│     │ serve    │
│         │     │ achieve?│     │ risk?   │     │ level     │     │ recs!    │
└─────────┘     └─────────┘     └─────────┘     └───────────┘     └──────────┘
                                                                       │
                                                                       ▼
                                                              user_insights row
                                                              is fully populated
```

> **Key principle**: Profiling questions are woven naturally into the conversation — never presented as a rigid form. The LLM adapts follow-up questions based on previous answers.

---

## Directory Structure

```
et-financial-concierge/
├── frontend/                     # Flutter application
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/               # Data models (User, Message, Recommendation)
│   │   ├── providers/            # State management (Riverpod/Bloc)
│   │   ├── screens/              # Chat, Profile, Discover, Settings
│   │   ├── services/             # API client, auth service
│   │   ├── widgets/              # ChatBubble, RecCard, ProfileCard
│   │   └── utils/                # Theme, constants, helpers
│   ├── pubspec.yaml
│   └── test/
│
├── backend/                      # FastAPI application
│   ├── app/
│   │   ├── main.py               # FastAPI entry point
│   │   ├── api/
│   │   │   ├── v1/
│   │   │   │   ├── chat.py       # /chat endpoints
│   │   │   │   ├── user.py       # /user endpoints
│   │   │   │   ├── event.py      # /event endpoints
│   │   │   │   └── recommend.py  # /recommend endpoints
│   │   ├── core/
│   │   │   ├── config.py         # Settings & env vars
│   │   │   ├── security.py       # JWT, OAuth handlers
│   │   │   └── middleware.py     # Rate limiting, CORS, logging
│   │   ├── models/               # SQLAlchemy ORM models
│   │   ├── schemas/              # Pydantic request/response schemas
│   │   ├── services/
│   │   │   ├── ai_orchestrator.py    # RAG pipeline coordinator
│   │   │   ├── llm_service.py        # LLM API wrapper
│   │   │   ├── embedding_service.py  # Text → vector embeddings
│   │   │   ├── retrieval_service.py  # Vector similarity search
│   │   │   ├── profiling_service.py  # User insight extraction
│   │   │   └── recommendation_service.py
│   │   ├── prompts/              # Prompt templates (Jinja2)
│   │   └── db/
│   │       ├── session.py        # DB session management
│   │       └── migrations/       # Alembic migrations
│   ├── requirements.txt
│   ├── Dockerfile
│   └── tests/
│
├── schema.sql                    # Database schema (this repo)
├── docker-compose.yml            # PostgreSQL, Redis, API
├── .env.example
└── README.md                     # ← You are here
```

---

## Getting Started

### Prerequisites

- **Python** 3.11+
- **Flutter** 3.x (with Dart SDK)
- **PostgreSQL** 15+ (with `pgvector` extension)
- **Redis** 7+
- **Docker & Docker Compose** (recommended)

### 1. Clone & Configure

```bash
git clone https://github.com/your-org/et-financial-concierge.git
cd et-financial-concierge
cp .env.example .env
# Edit .env with your API keys and database credentials
```

### 2. Start Infrastructure

```bash
docker-compose up -d postgres redis
```

### 3. Initialize Database

```bash
psql -h localhost -U etconcierge -d etconcierge -f schema.sql
```

### 4. Run Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

API docs will be available at `http://localhost:8000/docs` (Swagger UI).

### 5. Run Frontend

```bash
cd frontend
flutter pub get
flutter run -d chrome            # or -d android / -d ios
```

---

## Environment Variables

| Variable | Description | Example |
|---|---|---|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://user:pass@localhost:5432/etconcierge` |
| `REDIS_URL` | Redis connection string | `redis://localhost:6379/0` |
| `OPENAI_API_KEY` | OpenAI API key for GPT-4 + embeddings | `sk-...` |
| `JWT_SECRET` | Secret key for JWT token signing | `your-256-bit-secret` |
| `JWT_EXPIRY_HOURS` | Token expiration duration | `24` |
| `ET_API_BASE_URL` | Base URL for ET internal APIs | `https://api.economictimes.com/v1` |
| `ET_API_KEY` | Authentication key for ET APIs | `et-key-...` |
| `PINECONE_API_KEY` | (Optional) Pinecone API key if using external vector DB | `pc-...` |
| `SENTRY_DSN` | (Optional) Error tracking | `https://...@sentry.io/...` |
| `LOG_LEVEL` | Logging verbosity | `INFO` |

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure all PRs include:
- Corresponding migration files for schema changes
- Unit tests for new API endpoints
- Updated API documentation

---

## License

This project is proprietary to **Times Internet Ltd.** and is not licensed for external use.

---

<p align="center">
  <em>Built with ❤️ for the Economic Times ecosystem</em>
</p>
