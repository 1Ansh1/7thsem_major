# Appendix A — Database Schema and Entity-Relationship Architecture

**Project:** PrepPath — AI-Powered Adaptive Placement Preparation Platform  
**Document:** Technical Schema Audit & Relational Database Specification  
**Output Location:** `docs/report_appendices/Appendix_A_Database/`  
**Generated On:** November 20, 2026  

---

## 1. Executive Summary & Inspection Scope

This technical document provides the formal audit and architectural specification of the relational database powering **PrepPath**. The investigation inspected both the live development runtime database and the authoritative SQLAlchemy declarative models to reconcile design-time definitions with actual persistence structures.

### Inspection Parameters
- **Active Runtime Engine:** SQLite 3 (database file: `major1/backend/dev.db`, size: ~508 KB)
- **Intended Production Engine:** PostgreSQL 16+ with `pgvector` extension (`postgresql+asyncpg://...`)
- **ORM Framework:** SQLAlchemy 2.0 (Declarative Base with `Mapped` and `mapped_column` type annotations)
- **Migration Management:** Alembic (Revisions: `0001_initial.py`, `0002_profile_last_active.py`, `0003_submission_mode.py`)
- **Total Entities Audited:** 27 relational tables (25 application domain entities + 1 Alembic version tracking table + 1 Many-to-Many association table)

---

## 2. Multi-Dialect Architecture (PostgreSQL vs. SQLite)

The platform implements an explicit multi-dialect database abstraction:

1. **Production Configuration (PostgreSQL + pgvector):**
   - Configured in `app/core/config.py` as `postgresql+asyncpg://USER:PASS@HOST/DB?ssl=require`.
   - Utilizes native `pgvector` `vector(768)` column type for semantic embeddings (`gemini-embedding-001` with 768 output dimensions).
   - Utilizes an **HNSW (Hierarchical Navigable Small World)** vector index on `documents.embedding` using cosine distance operator class (`vector_cosine_ops`) with parameters `m = 16, ef_construction = 64` (defined in Alembic migration `0001_initial.py`).
   - Foreign keys, native cascades, and timezone-aware timestamps (`TIMESTAMP WITH TIME ZONE`) are strictly enforced.

2. **Local Development / Test Configuration (SQLite):**
   - Active database file `major1/backend/dev.db`.
   - Utilizes a custom SQLAlchemy `TypeDecorator` (`app.models.base.Embedding`) which transparently serializes 768-dimensional float vectors as JSON arrays (`JSON(none_as_null=True)`) on non-Postgres engines.
   - Vector similarity search falls back to in-process cosine distance computation (`app.services.rag._cos`) using Python's `math.sqrt`.
   - Connection-level concurrency timeout of 30 seconds (`connect_args={"timeout": 30}`) is configured in `app/core/db.py` to prevent locking during concurrent async test runs.

---

## 3. Subsystem Domain Breakdown & Entity Responsibilities

The PrepPath database is structured into five distinct architectural domains:

### 3.1. Identity, Security & Student Profiles
- **`roles`**: Defines Role-Based Access Control (RBAC) tiers (`admin`, `content_manager`, `student`). Stores fine-grained permission scopes as JSON arrays.
- **`users`**: Core authentication record containing email (indexed, unique), Argon2/bcrypt password hash, Google OAuth2 subject ID (`google_sub`), user status, and audit timestamps.
- **`sessions`**: Refresh token lifecycle management supporting cryptographically secure token rotation chains with `family_id`, SHA-256 token hashing, revocation tracking, and user agent metadata.
- **`profiles`**: 1-to-1 extension of `users` storing academic background (college, branch, graduation year), placement intent (target role, target companies), benchmark domain scores (`dsa_score`, `csf_score`, etc.), study streak, and behavioral counters.

### 3.2. Curriculum, Skills & Knowledge Base (RAG)
- **`topics`**: Hierarchical classification tree of academic subjects (e.g., Data Structures, Operating Systems, DBMS, Aptitude) supporting self-referential parent-child relationships.
- **`skills`**: Fine-grained competencies mapped to topics. Serves as nodes in the directed skill graph with calibrated difficulty baselines.
- **`questions`**: Multimodal assessment items supporting Multiple Choice (`mcq`), Multi-Select, Numerical, and Coding problems. Contains schema-validated options, answers, explanations, and review workflows (`draft`, `published`, `ai_generated`).
- **`question_companies`**: Many-to-Many join table linking historical interview questions to specific corporate hiring tracks.
- **`documents`**: Granular knowledge chunks (average 900 characters with 150-character overlap) storing text content, metadata, source URIs, and 768-dimensional semantic embeddings for the AI Tutor RAG pipeline.

### 3.3. Assessment & Automated Evaluation
- **`tests`**: Assessment definitions supporting timed mock online assessments (OAs), company-specific screening tests, and adaptive practice sets with configurable negative marking and section breakdowns.
- **`test_questions`**: Ordered junction table binding questions to test sections with specific mark weightings and negative penalty rules.
- **`attempts`**: Runtime session record for a student test attempt, capturing progress state, elapsed time, submitted status, and percentage scores.
- **`submissions`**: Atomic record of student answers per question. Captures submitted code, programming language (`python`, `cpp`, `java`), execution time in milliseconds, and student confidence rating (1–5).
- **`verdicts`**: Execution and evaluation outcome of a submission, recording Judge0 automated test results (`Accepted`, `Wrong Answer`, `Time Limit Exceeded`), pass/fail flags, and score allocations.

### 3.4. Placement Readiness & Adaptive Personalisation
- **`companies`**: Comprehensive corporate profiles detailing hiring patterns, observed Online Assessment (OA) formats, syllabus skill weights, and optional custom readiness score weight overrides.
- **`readiness_scores`**: Historical log of computed Company Readiness Scores (Equation 3.1), storing overall readiness (0–100), breakdown of all 6 components, and applied weights.
- **`mastery`**: Persistent Bayesian skill state for a student on a specific skill node, tracking continuous mastery score (0–100), attempt counts, accuracy, and average solve time.
- **`progress`**: High-level milestone tracking mapping a student's completion status per topic (`not_started`, `in_progress`, `completed`).
- **`roadmaps`**: Dynamic personalized learning roadmaps generated based on diagnostic gaps and target company OA patterns.
- **`recommendations`**: Rule-based next-best-action recommendations targeting the student's highest-weighted readiness vulnerability.

### 3.5. Career Services, Mock Interviews & AI Telemetry
- **`resumes`**: Uploaded student resumes with parsing status and structured extraction payloads (skills, projects, education).
- **`job_descriptions`**: Target job openings parsed into core technical requirements for gap matching.
- **`interviews`**: End-to-end multi-turn mock interview transcripts, capturing question prompts, audio/text responses, category rubrics, and final interview readiness score.
- **`ai_traces`**: Production observability tracking every LLM invocation (Gemini Flash/Lite), capturing latency, prompt tokens, completion tokens, calculated cost in USD, guardrail success, and failure details.
- **`feedback`**: User feedback ratings and comments on study materials, AI tutor hints, and practice questions.
- **`notifications`**: User alerts regarding study streaks, deadline reminders, and roadmap milestones.
- **`user_engagement`**: Gamification state tracking XP, badges earned, and leaderboard participation.

---

## 4. Key Relational Constraints and Cardinalities

| Source Entity | Target Entity | Cardinality | Constraint / Foreign Key | On Delete Behavior |
|---|---|---|---|---|
| `roles` | `users` | 1 : N | `users.role_id -> roles.id` | RESTRICT |
| `users` | `profiles` | 1 : 1 | `profiles.user_id -> users.id` (Unique) | CASCADE |
| `users` | `sessions` | 1 : N | `sessions.user_id -> users.id` | CASCADE |
| `users` | `attempts` | 1 : N | `attempts.user_id -> users.id` | CASCADE |
| `users` | `submissions`| 1 : N | `submissions.user_id -> users.id` | CASCADE |
| `submissions`| `verdicts` | 1 : 1 | `verdicts.submission_id -> submissions.id` | CASCADE |
| `users` | `mastery` | 1 : N | `mastery.user_id -> users.id` | CASCADE |
| `skills` | `mastery` | 1 : N | `mastery.skill_id -> skills.id` | CASCADE |
| `topics` | `skills` | 1 : N | `skills.topic_id -> topics.id` | SET NULL |
| `topics` | `questions` | 1 : N | `questions.topic_id -> topics.id` | SET NULL |
| `questions` | `question_companies` | 1 : N | `question_companies.question_id -> questions.id` | CASCADE |
| `companies` | `question_companies` | 1 : N | `question_companies.company_id -> companies.id` | CASCADE |
| `tests` | `test_questions` | 1 : N | `test_questions.test_id -> tests.id` | CASCADE |
| `questions` | `test_questions` | 1 : N | `test_questions.question_id -> questions.id` | CASCADE |
| `users` | `readiness_scores` | 1 : N | `readiness_scores.user_id -> users.id` | CASCADE |
| `companies` | `readiness_scores` | 1 : N | `readiness_scores.company_id -> companies.id` | CASCADE |
| `users` | `interviews` | 1 : N | `interviews.user_id -> users.id` | CASCADE |
| `users` | `ai_traces` | 1 : N | `ai_traces.user_id -> users.id` | SET NULL |

---

## 5. Audit of Schema Discrepancies

During technical inspection, three specific discrepancies between runtime persistence, migrations, and declarative models were cataloged:

1. **Module 16 Extension Tables (`notifications` & `user_engagement`):**
   - Both models are formally defined in SQLAlchemy declarative metadata (`major1/backend/app/models/domain.py`) with complete relationship definitions.
   - The initial Alembic migration series (`0001` through `0003`) established the foundational assessment and practice database before Module 16 engagement extensions were finalized.
   - As a consequence, the active local `dev.db` contains 25 application tables, while the SQLAlchemy metadata reflects the complete 27 tables. Both are documented in `Database_Schema.sql`.

2. **Vector Embedding Storage:**
   - On PostgreSQL, `documents.embedding` is declared as `vector(768)` backed by an HNSW cosine index.
   - On SQLite, the `Embedding` custom type compiles to `JSON`, with semantic cosine distance computed at the application service tier (`app/services/rag.py`).

3. **Temporal Normalization (`as_utc`):**
   - SQLite does not preserve timezone information on `DATETIME` columns.
   - The backend includes an explicit model helper (`app.models.base.as_utc`) to normalize timestamps on query read, ensuring timezone-aware comparisons across Python business logic.
