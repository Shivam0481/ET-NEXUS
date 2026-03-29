-- ============================================================================
-- ET NEXUS — DATABASE SCHEMA
-- PostgreSQL 15+
-- ============================================================================
-- This schema supports a multi-layered AI concierge system for Economic Times
-- that profiles users conversationally, tracks behavior, stores content
-- embeddings for RAG retrieval, and generates personalized recommendations.
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "vector";          -- pgvector for embedding storage


-- ============================================================================
-- 1. USERS — Core identity & authentication
-- ============================================================================
CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email           VARCHAR(255) NOT NULL UNIQUE,
    full_name       VARCHAR(200) NOT NULL,
    phone           VARCHAR(20),
    avatar_url      TEXT,
    auth_provider   VARCHAR(50)  NOT NULL DEFAULT 'email',       -- email | google | apple
    hashed_password TEXT,                                         -- NULL for OAuth users
    is_verified     BOOLEAN      NOT NULL DEFAULT FALSE,
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
    et_prime_member BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email       ON users (email);
CREATE INDEX idx_users_created_at  ON users (created_at);


-- ============================================================================
-- 2. USER_INSIGHTS — Financial profile derived from conversations
-- ============================================================================
-- Each row is a living snapshot that the AI orchestration layer updates
-- after every meaningful conversation turn.
CREATE TABLE user_insights (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Financial profile
    income_bracket      VARCHAR(50),          -- e.g. '5L-10L', '10L-25L', '25L-50L', '50L+'
    investment_horizon  VARCHAR(50),          -- short_term | medium_term | long_term
    risk_appetite       VARCHAR(30),          -- conservative | moderate | aggressive
    financial_goals     JSONB DEFAULT '[]',   -- ["retirement", "child_education", "wealth_creation"]
    preferred_sectors   JSONB DEFAULT '[]',   -- ["technology", "pharma", "banking"]
    existing_portfolio  JSONB DEFAULT '{}',   -- {"mutual_funds": true, "stocks": true, "fd": false, ...}

    -- Knowledge & experience
    experience_level    VARCHAR(30),          -- beginner | intermediate | advanced
    knowledge_areas     JSONB DEFAULT '[]',   -- ["equity", "mutual_funds", "tax_planning"]

    -- Engagement preferences
    preferred_content   JSONB DEFAULT '[]',   -- ["articles", "masterclasses", "live_events"]
    notification_prefs  JSONB DEFAULT '{}',   -- {"email": true, "push": true, "sms": false}

    -- Confidence scores (0.0 – 1.0) — how sure the AI is about each insight
    confidence_scores   JSONB DEFAULT '{}',   -- {"risk_appetite": 0.85, "income_bracket": 0.6}

    -- Metadata
    profiling_complete  BOOLEAN     NOT NULL DEFAULT FALSE,
    last_profiled_at    TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_user_insights UNIQUE (user_id)
);


-- ============================================================================
-- 3. USER_EVENTS — Behavioral event stream (click-stream / interaction log)
-- ============================================================================
CREATE TABLE user_events (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_type      VARCHAR(100) NOT NULL,    -- page_view | article_read | course_enroll
                                               -- chat_message | recommendation_click
                                               -- product_inquiry | event_register
    event_source    VARCHAR(50)  NOT NULL DEFAULT 'app',  -- app | web | api
    entity_type     VARCHAR(50),              -- article | product | event | masterclass
    entity_id       UUID,                     -- FK resolved at app level (polymorphic)
    event_data      JSONB DEFAULT '{}',       -- arbitrary payload (scroll %, duration, etc.)
    session_id      UUID,                     -- ties to sessions table
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_user_events_user      ON user_events (user_id, created_at DESC);
CREATE INDEX idx_user_events_type      ON user_events (event_type);
CREATE INDEX idx_user_events_entity    ON user_events (entity_type, entity_id);
CREATE INDEX idx_user_events_session   ON user_events (session_id);


-- ============================================================================
-- 4. PRODUCTS — ET services & financial partner offerings
-- ============================================================================
CREATE TABLE products (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(300) NOT NULL,
    slug            VARCHAR(300) NOT NULL UNIQUE,
    category        VARCHAR(100) NOT NULL,    -- et_prime | masterclass | event
                                               -- mutual_fund | insurance | loan
                                               -- stock_advisory | tax_tool
    sub_category    VARCHAR(100),
    provider        VARCHAR(200),             -- 'ET' or partner name
    description     TEXT,
    features        JSONB DEFAULT '[]',       -- ["live_sessions", "certificate", ...]
    pricing         JSONB DEFAULT '{}',       -- {"amount": 4999, "currency": "INR", "billing": "yearly"}
    risk_category   VARCHAR(30),              -- conservative | moderate | aggressive (for fin products)
    suitability     JSONB DEFAULT '{}',       -- {"min_experience": "beginner", "goals": ["retirement"]}
    url             TEXT,
    image_url       TEXT,
    is_active       BOOLEAN     NOT NULL DEFAULT TRUE,
    metadata        JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_products_category  ON products (category);
CREATE INDEX idx_products_active    ON products (is_active) WHERE is_active = TRUE;
CREATE INDEX idx_products_slug      ON products (slug);


-- ============================================================================
-- 5. CONTENT — Articles, courses, masterclass material with embeddings
-- ============================================================================
CREATE TABLE content (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title           VARCHAR(500) NOT NULL,
    slug            VARCHAR(500) NOT NULL UNIQUE,
    content_type    VARCHAR(50)  NOT NULL,     -- article | course | masterclass_material
                                                -- video | podcast | report | newsletter
    source          VARCHAR(100) NOT NULL DEFAULT 'et_prime',  -- et_prime | et_markets | et_wealth
    author          VARCHAR(200),
    summary         TEXT,
    body            TEXT,                       -- full text (used for chunking & embedding)
    tags            JSONB DEFAULT '[]',         -- ["mutual_funds", "SIP", "tax_saving"]
    sectors         JSONB DEFAULT '[]',         -- ["banking", "IT"]
    difficulty      VARCHAR(30),               -- beginner | intermediate | advanced
    is_premium      BOOLEAN     NOT NULL DEFAULT FALSE,
    url             TEXT,
    image_url       TEXT,

    -- Vector embedding for semantic search (RAG)
    -- 1536 dimensions = OpenAI text-embedding-ada-002; adjust for your model
    embedding       vector(1536),

    published_at    TIMESTAMPTZ,
    is_active       BOOLEAN     NOT NULL DEFAULT TRUE,
    metadata        JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_content_type       ON content (content_type);
CREATE INDEX idx_content_source     ON content (source);
CREATE INDEX idx_content_premium    ON content (is_premium);
CREATE INDEX idx_content_published  ON content (published_at DESC);
CREATE INDEX idx_content_slug       ON content (slug);

-- HNSW index for fast approximate nearest-neighbor search on embeddings
CREATE INDEX idx_content_embedding  ON content
    USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);


-- ============================================================================
-- 6. CONTENT_CHUNKS — Chunked content for granular RAG retrieval
-- ============================================================================
CREATE TABLE content_chunks (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    content_id      UUID NOT NULL REFERENCES content(id) ON DELETE CASCADE,
    chunk_index     INT  NOT NULL,             -- ordering within the parent content
    chunk_text      TEXT NOT NULL,
    token_count     INT,
    embedding       vector(1536),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_chunks_content     ON content_chunks (content_id, chunk_index);
CREATE INDEX idx_chunks_embedding   ON content_chunks
    USING ivfflat (embedding vector_cosine_ops) WITH (lists = 200);


-- ============================================================================
-- 7. RECOMMENDATIONS — Personalized outputs from the AI pipeline
-- ============================================================================
CREATE TABLE recommendations (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    conversation_id     UUID,                  -- ties to conversations table (nullable for batch recs)

    -- What is being recommended
    recommendation_type VARCHAR(50)  NOT NULL,  -- product | content | action | portfolio_rebalance
    entity_type         VARCHAR(50),            -- product | content | event
    entity_id           UUID,                   -- FK resolved at app level

    -- AI-generated output
    title               VARCHAR(500),
    explanation         TEXT NOT NULL,           -- human-readable reasoning (explainability)
    confidence_score    FLOAT CHECK (confidence_score BETWEEN 0.0 AND 1.0),
    relevance_factors   JSONB DEFAULT '[]',     -- ["matches_goal:retirement", "risk_aligned", ...]

    -- Context used to generate
    prompt_snapshot     TEXT,                    -- the assembled prompt sent to LLM
    context_sources     JSONB DEFAULT '[]',     -- IDs of content chunks / products used in RAG
    model_version       VARCHAR(100),           -- e.g. "gpt-4-turbo-2024-04-09"

    -- User feedback
    status              VARCHAR(30)  NOT NULL DEFAULT 'pending',  -- pending | viewed | accepted | dismissed
    user_rating         SMALLINT CHECK (user_rating BETWEEN 1 AND 5),
    user_feedback       TEXT,

    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    expires_at          TIMESTAMPTZ                               -- time-sensitive recs
);

CREATE INDEX idx_recs_user          ON recommendations (user_id, created_at DESC);
CREATE INDEX idx_recs_conversation  ON recommendations (conversation_id);
CREATE INDEX idx_recs_status        ON recommendations (status);
CREATE INDEX idx_recs_type          ON recommendations (recommendation_type);


-- ============================================================================
-- 8. CONVERSATIONS — Chat sessions between user and the concierge
-- ============================================================================
CREATE TABLE conversations (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title           VARCHAR(300),              -- auto-generated summary of the chat
    status          VARCHAR(30) NOT NULL DEFAULT 'active',  -- active | archived | deleted
    intent_tags     JSONB DEFAULT '[]',        -- ["investment_query", "event_discovery"]
    profiling_stage VARCHAR(50),               -- intro | goals | risk | portfolio | complete
    summary         TEXT,                      -- running LLM-generated summary
    message_count   INT NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_conversations_user ON conversations (user_id, created_at DESC);


-- ============================================================================
-- 9. MESSAGES — Individual messages within a conversation
-- ============================================================================
CREATE TABLE messages (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    role            VARCHAR(20)  NOT NULL,      -- user | assistant | system
    content         TEXT         NOT NULL,
    intent          VARCHAR(100),               -- detected intent for user messages
    entities        JSONB DEFAULT '[]',          -- extracted entities: [{"type":"ticker","value":"RELIANCE"}]
    tool_calls      JSONB DEFAULT '[]',          -- any function/tool calls the LLM made
    token_usage     JSONB DEFAULT '{}',          -- {"prompt": 500, "completion": 200, "total": 700}
    latency_ms      INT,                         -- response time tracking
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_messages_conversation ON messages (conversation_id, created_at);


-- ============================================================================
-- 10. SESSIONS — Application sessions for analytics & cache keying
-- ============================================================================
CREATE TABLE sessions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_info     JSONB DEFAULT '{}',         -- {"platform":"android","version":"3.2.1"}
    ip_address      INET,
    started_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at        TIMESTAMPTZ,
    is_active       BOOLEAN     NOT NULL DEFAULT TRUE
);

CREATE INDEX idx_sessions_user ON sessions (user_id, started_at DESC);


-- ============================================================================
-- 11. FEEDBACK — Explicit user feedback on the concierge experience
-- ============================================================================
CREATE TABLE feedback (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    conversation_id UUID REFERENCES conversations(id) ON DELETE SET NULL,
    rating          SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    category        VARCHAR(50),               -- accuracy | relevance | speed | ux
    comment         TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_feedback_user ON feedback (user_id);


-- ============================================================================
-- 12. PROMPT_TEMPLATES — Versioned prompt templates for the AI layer
-- ============================================================================
CREATE TABLE prompt_templates (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(200) NOT NULL UNIQUE,   -- e.g. "profiling_risk_assessment"
    template        TEXT         NOT NULL,           -- Jinja2/Mustache-style template
    version         INT          NOT NULL DEFAULT 1,
    variables       JSONB DEFAULT '[]',             -- expected variable keys
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);


-- ============================================================================
-- 13. AUDIT_LOG — Immutable log for compliance & debugging
-- ============================================================================
CREATE TABLE audit_log (
    id              BIGSERIAL PRIMARY KEY,
    user_id         UUID,
    action          VARCHAR(200) NOT NULL,     -- api_call | recommendation_generated | login | ...
    resource_type   VARCHAR(100),
    resource_id     UUID,
    details         JSONB DEFAULT '{}',
    ip_address      INET,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_user     ON audit_log (user_id, created_at DESC);
CREATE INDEX idx_audit_action   ON audit_log (action);


-- ============================================================================
-- UTILITY: Auto-update `updated_at` trigger
-- ============================================================================
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to all tables with an `updated_at` column
DO $$
DECLARE
    tbl TEXT;
BEGIN
    FOR tbl IN
        SELECT table_name
        FROM information_schema.columns
        WHERE column_name = 'updated_at'
          AND table_schema = 'public'
    LOOP
        EXECUTE format(
            'CREATE TRIGGER trg_%I_updated_at
             BEFORE UPDATE ON %I
             FOR EACH ROW EXECUTE FUNCTION set_updated_at();',
            tbl, tbl
        );
    END LOOP;
END;
$$;


-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
