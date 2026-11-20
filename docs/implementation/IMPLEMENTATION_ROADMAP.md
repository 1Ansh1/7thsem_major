# PrepPath: Implementation Roadmap

This roadmap organizes the development work required to transform the current codebase into the fully integrated, demonstrable platform described in the Major Project Report.

---

## Priority Progression & Milestones

### Phase A: Core Gaps & Readiness Completion (P0) — [COMPLETED]
1. **Mock Interview Subsystem (Module 13 & Report Table 3.3)**
   - Backend service `app/services/interview.py`:
     - Multi-turn conversation management (question, student answer, follow-up).
     - 5-dimension evaluation rubric (Technical Knowledge, Problem Solving, Communication, Confidence, Concept Accuracy on 1–10 scale).
     - Qualitative report generation (strengths, weaknesses, topics to revise).
   - Backend router `app/routers/interview.py`:
     - `POST /api/v1/interviews` (start session with company, role, difficulty).
     - `POST /api/v1/interviews/{id}/turn` (submit answer, receive adaptive follow-up).
     - `POST /api/v1/interviews/{id}/finish` (generate scores and report).
     - `GET /api/v1/interviews/{id}` and `GET /api/v1/interviews` (history).
   - Integration with Equation 3.1: Wire the resulting interview scores into `readiness_data.py` so the Interview component is dynamic rather than 0!
   - Frontend UI: `/interviews` directory and interactive interview room `/interviews/[id]`.

2. **Multi-Agent Orchestration & Adaptive Roadmaps (Module 14 & Report Section 3.8, 4.4)**
   - Agent orchestration framework (`app/services/agents/`):
     - Agent base classes, state schema, and handoff protocols.
     - 7 specialized agents:
       1. Triage Agent: Classifies intent and routes requests.
       2. Tutor Agent: Explains concepts with RAG grounding.
       3. Assessment Agent: Generates targeted tests.
       4. Interview Agent: Conducts mock interviews.
       5. Placement Agent: Generates company-specific schedules.
       6. Analytics Agent: Explains performance trends.
       7. Recommendation Agent: Determines next study actions.
   - Adaptive Roadmap Engine (`app/services/roadmap.py`):
     - Takes target company, timeline (days), current skill graph, weak topics.
     - Emits daily schedules (topics, concept revision, easy/medium problems, mini assessments).
     - Dynamic plan revision: when assessment performance drops in a topic, automatically adjusts remaining schedule (e.g., inserts BFS/DFS practice and postpones advanced DP).
     - Versioning and change explanation.
   - Backend router `app/routers/roadmap.py`:
     - `POST /api/v1/roadmaps/generate`
     - `GET /api/v1/roadmaps/active`
     - `POST /api/v1/roadmaps/{id}/revise`
   - Frontend UI: `/roadmap` interactive timeline and daily schedule view.

---

### Phase B: Student Privacy, Data Rights & Security (P1) — [COMPLETED]
1. **Student Data Export & Deletion (Module 1, Part 2.4, Report Section 6.2)**
   - Endpoint `GET /api/v1/users/me/export`: Compiles all student profile data, attempt history, test submissions, code verdicts, mastery records, resumes, and interview transcripts into a formatted JSON archive.
   - Endpoint `DELETE /api/v1/users/me`: Performs a verified cascading deletion of user records, removing uploaded resume files from disk.
   - Consent tracking and retention policy configuration.
   - Frontend profile UI additions (`/profile`) with clear "Export My Data" and "Delete My Account" controls.

---

### Phase C: Notifications & Engagement (P2) — [COMPLETED]
1. **Notification Subsystem (Module 16 & Report Section 3.11)**
   - Notification model (`Notification`, `NotificationPreference`) in SQLAlchemy.
   - 6 category dispatchers:
     - Daily study reminder
     - Scheduled test reminder
     - Weak-topic reminder (based on skill `last_attempt`)
     - Streak reminder
     - Weekly performance summary
     - Upcoming company deadline
   - Endpoints: `GET /api/v1/notifications`, `PATCH /api/v1/notifications/{id}/read`, `GET/PUT /api/v1/notifications/preferences`.
   - Frontend notification drawer and bell indicator.

2. **Engagement & Gamification Layer (Module 16 & Report Section 3.11)**
   - XP scoring from study completion, accepted code submissions, and tests.
   - Badges (e.g., "First Submission", "Graph Explorer", "Consistent Coder").
   - Opt-in leaderboard (disabled by default as mandated by institutional ethics).
   - Endpoints: `GET /api/v1/engagement/me`, `GET /api/v1/engagement/leaderboard`.

---

### Phase D: Academic Evaluation Harness & Benchmarking (P1) — [COMPLETED]
1. **Traceability Test Suite (`tests/test_functional_traceability.py`)**
   - Formal test cases covering T01 to T19 with matching IDs:
     - T01 (OAuth), T02 (RBAC), T03 (Study Mode), T04 (RAG citation & refusal), T05 (Test timer), T07 (Correct C++ submission), T08 (TLE), T10 (Sandbox isolation), T11 (Code review boundary), T12 (Mastery update), T13 (Readiness calculation), T14 (Question generation guardrails), T15 (Admin review), T16 (Resume/JD), T19 (Dashboard traceability).
2. **Assessment Pipeline Benchmark (`benchmarks/benchmark_pipeline.py`)**
   - Automated script executing 30+ iterations and logging Mean and P95 latencies for Table 5.1:
     - Question retrieval, test initialization, MCQ scoring, C++ Judge0 verdict, Python Judge0 verdict, Vector retrieval, Cached vs Uncached AI Tutor, Readiness computation.
3. **RAG Evaluation Harness (`benchmarks/rag_eval_harness.py`)**
   - Evaluation dataset of 20 representative QA pairs with ground-truth citations.
   - Evaluates: Faithfulness, Answer Relevance, Context Precision, Context Recall, Citation Accuracy, Refusal Correctness.

---

### Phase E: Production Hardening & DevOps (P1) — [COMPLETED]
1. **Containerization Topology (Report Figure 4.1)**
   - `backend/Dockerfile` (Multi-stage Python 3.12, Uvicorn, Celery).
   - `frontend/Dockerfile` (Multi-stage Node.js 22, Next.js standalone output).
   - `docker-compose.yml`:
     - `frontend` (port 3000)
     - `backend` (port 8000)
     - `postgres` (port 5432, with `pgvector/pgvector:pg16` image)
     - `redis` (port 6379)
     - `worker` (Celery background tasks)
     - `judge0` (Isolated code execution)
2. **CI/CD Hardening**
   - Update `.github/workflows/ci.yml` to run test suites, linting, frontend build, and Docker build checks.
