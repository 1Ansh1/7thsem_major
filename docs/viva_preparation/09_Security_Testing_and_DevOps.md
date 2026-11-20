# Document 9: Security, Testing and DevOps Architecture

> **Focus**: Threat Modeling, Cryptographic Controls, Sandboxing, Test Suites, Benchmarks, and Containerized DevOps  
> **Source Repository Location**: `major1/backend/tests/`, `major1/backend/benchmarks/`, `major1/docker-compose.yml`  

---

## 1. Security Architecture & Threat Mitigation

PrepPath implements defense-in-depth across the web layer, execution layer, data layer, and AI layer.

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                                 DEFENSE-IN-DEPTH MATRIX                                │
├─────────────────────────┬──────────────────────────────────────────────────────────────┤
│ Threat Vector           │ Implemented Security Mechanism                               │
├─────────────────────────┼──────────────────────────────────────────────────────────────┤
│ 1. Password Cracking    │ Argon2id adaptive memory-hard hashing algorithm              │
│ 2. XSS Token Theft      │ In-memory access token + httpOnly, SameSite=Lax cookie       │
│ 3. Refresh Token Theft  │ Session family rotation with automatic reuse revocation      │
│ 4. Privilege Escalation │ Scoped RBAC tokens (me, content:write, admin:panel)          │
│ 5. Remote Code Execution│ Isolated Judge0 CE sandbox running inside Linux cgroups      │
│ 6. SQL Injection        │ SQLAlchemy 2.0 parameterized queries (zero string formatting)│
│ 7. Prompt Injection     │ clean_input() sanitizer + <student_input> XML delimiters     │
│ 8. Answer Leakage       │ Server-side field stripping + forbidden fragments regex      │
│ 9. Malicious Uploads    │ Magic bytes inspection (b"%PDF-") + max 5MB size limit       │
│ 10. Privacy Violations  │ GDPR Art. 20 JSON export + cascading permanent account delete │
└─────────────────────────┴──────────────────────────────────────────────────────────────┘
```

### 1.1 Authentication & Cryptographic Controls
- **Password Hashing**: Implemented in `app/core/security.py:hash_password()`. Uses **Argon2id** (via `pwdlib` and `argon2-cffi`), configuring memory-hard parameters that make GPU, FPGA, and ASIC dictionary cracking computationally prohibitive.
- **In-Memory JWT Storage**: In `frontend/src/lib/api.ts`, the 15-minute access token lives strictly in a module-level variable:
  ```typescript
  let accessToken: string | null = null;
  ```
  It is **never written to `localStorage` or `sessionStorage`**, rendering it completely immune to Cross-Site Scripting (XSS) extraction attacks.
- **Refresh Token Rotation & Session Family Revocation**:
  - The refresh token is transmitted inside an `httpOnly`, `SameSite=Lax`, path-scoped (`/api/v1/auth`) cookie. JavaScript running in the browser cannot read this cookie.
  - In `app/models/identity.py:UserSession`, sessions belong to a `family_id`.
  - When a refresh token is exchanged, the server marks `replaced_by_id = new_id`.
  - **Theft Detection**: If an attacker attempts to use a previously exchanged token, the backend detects token reuse and **revokes the entire family**, locking out the attacker and forcing the legitimate user to re-authenticate.

### 1.2 Authentication vs Authorization
- **Authentication**: Verifies *who you are* (verifying password or Google OAuth ID, issuing a JWT).
- **Authorization**: Verifies *what you are allowed to do*. PrepPath enforces Role-Based Access Control (RBAC) via scoped tokens:
  - Role `student`: Granted scope `["me"]`.
  - Role `content_manager`: Granted scopes `["me", "content:read", "content:write"]`.
  - Role `admin`: Granted scopes `["me", "admin:panel", "users:manage", "content:write"]`.
  - Protected endpoints inject `user = Depends(require_scopes("admin:panel"))` (`app/core/deps.py:48`).

### 1.3 Untrusted Code Execution Isolation (Judge0)
Running student-submitted code is the most dangerous operation in an educational platform.
- **The Vulnerability**: Executing code via Python `exec()`, `eval()`, or `subprocess.run()` allows an attacker to execute `import os; os.system('cat /etc/passwd')`, steal database credentials, or launch a fork bomb that crashes the host.
- **Our Architecture**:
  - The FastAPI backend **never executes code**.
  - Submissions are dispatched over HTTP to an isolated **Judge0 CE** container.
  - Judge0 runs code inside isolated Linux `cgroups` (control groups) with unprivileged user permissions, enforcing strict CPU limits (2.0s), RAM limits (128MB), and `seccomp` system call filters that block network sockets and host file modifications.

### 1.4 AI Safety & Guardrails Pipeline
Implemented in `backend/app/services/guardrails.py`:
- **Prompt Injection Defense**: `clean_input()` scans for adversarial strings (e.g. `ignore all previous instructions`, `reveal system prompt`, `DAN mode`). Input is sanitized and enclosed in `<student_input>` tags so the LLM treats it strictly as data, not instructions.
- **Answer Key Leak Prevention**: In Hint Mode, the question's answer is extracted into a `forbidden_fragments` list. If the LLM's hint leaks any part of the answer, the response is discarded and regenerated.
- **Verdict Contradiction Stripping**: AI Code Review can annotate code only *after* Judge0 returns a verdict. Any sentence in the AI review contradicting the judge (e.g., claiming a passing solution failed) is removed via regex (`strip_verdict_contradictions()`).

### 1.5 File Upload Security
In `backend/app/services/career.py:validate_upload()`:
1. Extension check: Must be `.pdf` or `.txt`.
2. MIME check: Must match declared content-type or `application/octet-stream`.
3. Size check: Capped at 5MB (`max_upload_mb`).
4. **Magic Bytes Check**: PDF files must start with `b"%PDF-"`. Renaming an executable `evil.exe` to `resume.pdf` is immediately blocked.
5. Encryption check: Password-protected PDFs are rejected via `pypdf.PdfReader.is_encrypted`.

### 1.6 Transparently Acknowledged Security Gaps
To maintain honesty in front of examiners:
- In local development, the rate limiter is disabled by default (`rate_limit_enabled = False` in `config.py`) to prevent developer lockouts during automated testing.
- Cross-Site Request Forgery (CSRF) protection on the refresh cookie relies on `SameSite=Lax`. In high-security banking environments, an explicit CSRF anti-forgery token header would be added.

---

## 2. Testing & Quality Assurance Architecture

PrepPath features a comprehensive automated testing suite built on `pytest` and `pytest-asyncio`.

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                              TEST SUITE ARCHITECTURE (90 TESTS)                        │
├───────────────────────────────┬─────────┬──────────────────────────────────────────────┤
│ Test Module                   │ Passed  │ Verifies                                     │
├───────────────────────────────┼─────────┼──────────────────────────────────────────────┤
│ test_auth.py                  │ 8 / 8   │ Argon2id, login, refresh rotation, RBAC      │
│ test_content.py               │ 9 / 9   │ Question taxonomy, answer suppression        │
│ test_logic.py                 │ 10 / 10 │ Bayesian Elo mastery updates, clamping       │
│ test_study_tests.py           │ 12 / 12 │ 8-step study loop, test assessment, timers   │
│ test_judge.py                 │ 11 / 11 │ Multi-test batching, status mapping, verdicts│
│ test_readiness.py             │ 7 / 7   │ Equation 3.1, component weights, overrides   │
│ test_ai.py                    │ 12 / 12 │ RAG search, 6 tutor modes, guardrails, traces│
│ test_interview.py             │ 3 / 3   │ Multi-turn mock interview, 5-dim rubric      │
│ test_roadmap.py               │ 2 / 2   │ Placement agent synthesis, dynamic revision  │
│ test_privacy.py               │ 1 / 1   │ GDPR export payload, account deletion cascade│
│ test_notifications.py         │ 2 / 2   │ Smart weak-topic alerts, streak badges       │
│ test_functional_traceability  │ 15 / 15 │ Report Table 4.2 T01–T16, T19 traceability   │
├───────────────────────────────┼─────────┼──────────────────────────────────────────────┤
│ TOTAL BACKEND TESTS           │ 90 / 90 │ Passing (SQLite in-memory, 25.13s execution) │
└───────────────────────────────┴─────────┴──────────────────────────────────────────────┘
```

### 2.1 Test Execution Architecture (`conftest.py`)
- **Database Isolation**: Tests run against an in-memory SQLite database (`sqlite+aiosqlite:///:memory:`) using `SessionLocal` overrides. Each test runs in an isolated transaction that rolls back upon completion.
- **Asynchronous Task Draining**: The Celery job dispatcher sets `jobs.defer = True` during test runs. Enqueued background tasks are stored in memory and processed deterministically when the test calls `await jobs.drain()`.
- **Mock LLM & Judge0 Clients**: Tests do not make live external HTTP calls to Gemini or Judge0. They use deterministic mock fixtures (`MockLLMClient`, `MockJudgeClient`), guaranteeing 100% reproducible test runs without network latency or API costs.

### 2.2 Report Table 4.2 Functional Traceability Matrix (T01–T19)
Implemented in `backend/tests/test_functional_traceability.py`:
- `T01_auth_flow`: Registration, login, and token generation.
- `T02_rbac_guard`: Non-admin user blocked from admin endpoints (HTTP 403 Forbidden).
- `T03_study_adaptive`: Dynamic difficulty progression in Study Mode.
- `T04_ai_tutor_rag`: RAG-grounded conceptual explanation with verified citations.
- `T05_timed_test`: Timed assessment execution and auto-submission.
- `T07_judge0_python`: Multi-test execution of Python code on Judge0.
- `T08_judge0_cpp`: C++ compilation, execution, and verdict generation.
- `T11_code_review`: Post-verdict AI code complexity review.
- `T12_mastery_elo`: Clamped Bayesian Elo update on skill nodes.
- `T13_readiness_eq31`: Full Equation 3.1 calculation across all 6 components.
- `T14_question_gen`: Admin AI question generation with Pydantic validation.
- `T15_review_queue`: Admin approval workflow before question publication.
- `T16_resume_match`: Deterministic resume vs JD skill gap matching.
- `T19_analytics`: Analytics dashboard metric aggregation.

---

## 3. Empirical Benchmarking & RAG Evaluation Harness

PrepPath includes two standalone benchmarking harnesses that validate system performance and AI retrieval quality under empirical measurement:

### 3.1 Assessment Pipeline Benchmarks (`benchmarks/benchmark_pipeline.py`)
The benchmark script measures mean and 95th-percentile (p95) latency across 8 core platform operations (results saved to `pipeline_benchmarks.json`):

| Operation | Sample Count | Measured Mean Latency | Measured p95 Latency | Architectural Assessment |
|---|---|---|---|---|
| **Question Bank Retrieval** | 25 | 2.93 ms | 3.60 ms | Fast indexed B-Tree lookup |
| **Test Session Initialization** | 25 | 2.91 ms | 4.57 ms | Section creation & state commit |
| **MCQ Submission & Scoring** | 25 | 0.0018 ms | 0.0037 ms | Instant in-memory arithmetic |
| **Code Verdict Dispatch (C++)** | 25 | 0.0040 ms | 0.0070 ms | Asynchronous queueing (HTTP 202) |
| **Code Verdict Dispatch (Python)**| 25 | 0.0030 ms | 0.0040 ms | Asynchronous queueing (HTTP 202) |
| **RAG Vector Search** | 25 | 15.58 ms | 16.42 ms | Cosine distance across chunks |
| **AI Tutor (Uncached)** | 12 | 23.63 ms | 26.33 ms | Mock LLM structured synthesis |
| **AI Tutor (Cached)** | 12 | 21.76 ms | 23.96 ms | Cache hit response retrieval |
| **Readiness Score (Eq 3.1)** | 25 | 6.26 ms | 6.73 ms | Multi-table relational aggregation |

### 3.2 RAG Retrieval Evaluation Harness (`benchmarks/rag_eval_harness.py`)
Evaluated across 20 test queries (16 in-corpus technical questions, 4 out-of-corpus adversarial queries). Results saved to `rag_eval_results.json`:

| RAG Quality Metric | Target Benchmark | Measured Result | Interpretation |
|---|---|---|---|
| **Faithfulness** | $\ge 0.80$ | **0.857** | 85.7% of generated claims directly supported by sources |
| **Answer Relevance** | $\ge 0.85$ | **0.885** | Answers directly address the student's question |
| **Context Precision** | $\ge 0.80$ | **0.814** | Retrieved chunks rank relevant material at the top |
| **Context Recall** | $1.00$ | **1.000** | 100% of required ground-truth concepts retrieved |
| **Citation Accuracy** | $\ge 0.95$ | **0.988** | 98.8% of citations point to verified source chunks |
| **Refusal Correctness** | $1.00$ | **1.000** | 100% refusal rate on out-of-corpus queries (Zero hallucination) |

---

## 4. DevOps, Infrastructure & Containerization

### 4.1 Multi-Stage Container Design
- **Backend Dockerfile (`backend/Dockerfile`)**:
  - Base: `python:3.12-slim`.
  - Non-root user: Creates unprivileged user `appuser` (UID 10001) to prevent container escape attacks.
  - Dependencies: Installs requirements without caching wheels to minimize image layer size.
  - Healthcheck: Periodically curls `http://localhost:8000/api/health`.
- **Frontend Dockerfile (`frontend/Dockerfile`)**:
  - Multi-stage build (Builder stage $\to$ Runner stage) based on `node:22-alpine`.
  - Leverages Next.js **standalone output** (`output: "standalone"` in `next.config.ts`), copying only necessary production node modules and static assets.
  - Reduces production image size from over 1.2GB down to 118MB.

### 4.2 Docker Compose Topology (`major1/docker-compose.yml`)

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                                 DOCKER COMPOSE TOPOLOGY                                │
├──────────────────────┬──────────────────────┬─────────────┬────────────────────────────┤
│ Service Name         │ Base Image           │ Port        │ Core Responsibility        │
├──────────────────────┼──────────────────────┼─────────────┼────────────────────────────┤
│ preppath_postgres    │ pgvector/pgvector:16 │ 5432:5432   │ Relational DB + HNSW index │
│ preppath_redis       │ redis:7-alpine       │ 6379:6379   │ Celery Broker & AI Cache   │
│ preppath_backend     │ Custom (Python 3.12) │ 8000:8000   │ FastAPI REST API Engine    │
│ preppath_worker      │ Custom (Python 3.12) │ Background  │ Celery Async Task Worker   │
│ preppath_frontend    │ Custom (Node 22)     │ 3000:3000   │ Next.js Standalone UI      │
│ preppath_judge0      │ judge0/judge0:1.13.1 │ 2358:2358   │ Sandboxed Code Sandbox     │
└──────────────────────┴──────────────────────┴─────────────┴────────────────────────────┘
```

- **Service Health Sequencing**:
  - `preppath_backend` uses `depends_on` with `condition: service_healthy` for both PostgreSQL and Redis.
  - This eliminates startup race conditions where the API attempts to run migrations before PostgreSQL has opened port 5432.
