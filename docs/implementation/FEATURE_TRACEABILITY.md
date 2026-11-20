# PrepPath: Feature Traceability Matrix

This matrix maps every requirement from the Major Project Report and project prompt to its implementation status, code locations, APIs, and verification evidence.

## Status Definitions
- **VERIFIED IMPLEMENTED**: Working functionality with supporting tests and verification evidence.
- **PARTIALLY IMPLEMENTED**: Partial functionality exists, but specific report requirements remain missing.
- **NOT IMPLEMENTED**: Designed or promised, but no meaningful code exists yet.
- **IMPLEMENTED BUT BROKEN**: Code exists but fails execution or integration.
- **BLOCKED**: Implementation depends on external credentials or resources.

---

## 1. Feature Traceability Table

| ID | Feature Name | Report Reference | Status | Frontend Files | Backend Files | Database Tables | APIs | Tests / Verification | Priority |
|---|---|---|---|---|---|---|---|---|---|
| **F01** | Student Registration & Auth | §3.2, T01 | **VERIFIED IMPLEMENTED** | `src/app/login/`, `src/app/register/`, `src/lib/auth.tsx` | `app/routers/auth.py`, `app/models/identity.py` | `users`, `roles`, `sessions` | `POST /api/v1/auth/register`, `/login`, `/refresh`, `/logout` | `test_auth.py` | P0 |
| **F02** | Google OAuth2 Sign-In | §3.2, T01 | **VERIFIED IMPLEMENTED** | `src/app/login/`, `src/app/auth/callback/` | `app/routers/auth.py` | `users`, `sessions` | `GET /api/v1/auth/google/start`, `/callback` | `test_auth.py` (demo identity) | P0 |
| **F03** | RBAC Enforcement | §3.2, T02 | **VERIFIED IMPLEMENTED** | `src/components/Guard.tsx`, `AppShell.tsx` | `app/core/deps.py`, `app/routers/users.py` | `roles`, `users` | Token scopes (`me`, `content:write`, `admin:panel`) | `test_auth.py:test_rbac_forbidden` | P0 |
| **F04** | Student Profile & Targets | §3.2, §4.2 | **VERIFIED IMPLEMENTED** | `src/app/(app)/profile/page.tsx` | `app/routers/users.py`, `app/models/identity.py` | `profiles` | `GET /api/v1/users/me/profile`, `PUT /profile` | `test_auth.py` | P0 |
| **F05** | Student Data Privacy (Export & Delete) | §6.2, Part 2.4 | **NOT IMPLEMENTED** | Missing in `profile/page.tsx` | Missing in `app/routers/users.py` | All student-owned tables | `GET /api/v1/users/me/export`, `DELETE /api/v1/users/me` | Needs new tests | P1 |
| **F06** | Company Intelligence Profiles | §3.3, Fig 3.3 | **VERIFIED IMPLEMENTED** | `src/app/(app)/companies/`, `src/components/company.tsx` | `app/routers/companies.py`, `app/models/domain.py` | `companies` | `GET /api/v1/companies`, `GET /companies/{slug}` | `test_content.py` | P1 |
| **F07** | Company Data Disclaimer | §3.3, §6.2 | **VERIFIED IMPLEMENTED** | `src/components/company.tsx` | `app/routers/companies.py` | `companies` | Injected as `pattern_disclaimer` | Verified in API & UI | P1 |
| **F08** | Question Bank Taxonomy | §3.1, §3.3 | **VERIFIED IMPLEMENTED** | `src/app/(app)/questions/`, `QuestionTable.tsx` | `app/routers/questions.py`, `app/routers/topics.py` | `topics`, `questions`, `skills` | `GET /api/v1/questions`, `GET /topics` | `test_content.py` | P1 |
| **F09** | Adaptive Study Mode Loop | §3.4, Fig 3.4, T03 | **VERIFIED IMPLEMENTED** | `src/app/(app)/study/` | `app/routers/study.py`, `app/services/content.py` | `attempts`, `submissions` | `POST /api/v1/study/sessions`, `/answer`, `/complete` | `test_study_tests.py` | P1 |
| **F10** | Hierarchical Skill Graph | §3.6, Fig 3.6 | **VERIFIED IMPLEMENTED** | `src/app/(app)/skills/page.tsx` | `app/services/skill_graph.py`, `app/routers/progress.py` | `skills`, `mastery` | `GET /api/v1/progress/skills` | `test_logic.py` | P1 |
| **F11** | Deterministic Mastery Updates | §3.6, T12 | **VERIFIED IMPLEMENTED** | Rendered in Mastery bars | `app/services/mastery.py` | `mastery` | Pure service function | `test_logic.py:test_mastery_update_*` | P1 |
| **F12** | Test Mode Assessment Engine | §3.7, T05 | **VERIFIED IMPLEMENTED** | `src/app/(app)/tests/attempt/` | `app/routers/tests.py`, `app/services/grading.py` | `tests`, `attempts`, `submissions` | `POST /api/v1/tests/{id}/attempts`, `PUT /answers` | `test_study_tests.py` | P1 |
| **F13** | Monaco Editor & Judge0 Pipeline | §3.7, Fig 3.7, T07, T08 | **VERIFIED IMPLEMENTED** | `CodeWorkbench.tsx`, `CodeEditor.tsx` | `app/services/judge.py`, `judging.py`, `submissions.py`| `submissions`, `verdicts` | `POST /api/v1/submissions`, `GET /submissions/{id}` | `test_judge.py` | P0 |
| **F14** | Company Readiness Score (Eq. 3.1) | §3.10, T13 | **PARTIALLY IMPLEMENTED** | `ReadinessReportView.tsx` | `app/services/readiness.py`, `readiness_data.py` | `readiness_scores` | `GET /api/v1/progress/readiness/{slug}` | `test_readiness.py` (Interview hardcoded to 0) | P0 |
| **F15** | Student Analytics Dashboard | §3.11, Fig 4.4, T19 | **VERIFIED IMPLEMENTED** | `src/app/(app)/analytics/page.tsx`, `charts.tsx` | `app/routers/progress.py` | Stored attempt records | `GET /api/v1/progress/analytics` | `test_study_tests.py` | P1 |
| **F16** | RAG Ingestion & Vector Search | §3.5, Fig 3.5 | **VERIFIED IMPLEMENTED** | `src/app/(app)/admin/knowledge/` | `app/routers/kb.py`, `app/services/rag.py` | `documents` (pgvector / HNSW) | `POST /api/v1/kb/documents`, `/upload` | `test_ai.py` | P1 |
| **F17** | AI Tutor (6 Bounded Modes) | §3.5, T04 | **VERIFIED IMPLEMENTED** | `src/app/(app)/tutor/page.tsx` | `app/routers/ai.py`, `app/services/tutor.py` | `ai_traces` | `POST /api/v1/ai/tutor/{explain,hint,...}` | `test_ai.py` | P1 |
| **F18** | AI Code Review | §3.7, T11 | **VERIFIED IMPLEMENTED** | `src/components/CodeReviewPanel.tsx` | `app/services/code_review.py` | `verdicts` | `POST /api/v1/submissions/{id}/review` | `test_ai.py:test_code_review_*` | P1 |
| **F19** | Resume & JD Gap Analysis | §3.11, T16 | **VERIFIED IMPLEMENTED** | `src/app/(app)/career/page.tsx` | `app/routers/career.py`, `app/services/career.py` | `resumes`, `job_descriptions` | `POST /api/v1/career/resume`, `GET /gap` | `test_ai.py:test_resume_*` | P1 |
| **F20** | AI Question Generation & Review | §3.12, Fig 3.8a, T14, T15 | **VERIFIED IMPLEMENTED** | `src/app/(app)/admin/review/` | `app/services/generation.py`, `app/routers/ai.py` | `questions` | `POST /api/v1/ai/questions/generate`, `/approve` | `test_ai.py:test_review_queue_*` | P1 |
| **F21** | AI Observability & Cost Control | §3.12, §5.3 | **VERIFIED IMPLEMENTED** | `src/app/(app)/admin/ai/page.tsx` | `app/services/llm.py`, `app/routers/ai.py` | `ai_traces` | `GET /api/v1/ai/stats` | `test_ai.py:test_observability_*` | P1 |
| **F22** | Interactive Mock Interview System | §3.8, Table 3.3 | **VERIFIED IMPLEMENTED** | `src/app/(app)/interview/page.tsx` | `app/routers/interview.py`, `app/services/interview.py` | `interviews` | `POST /api/v1/interviews`, `/turn`, `/finish` | `test_interview.py` (3/3 pass) | P0 |
| **F23** | Multi-Agent Orchestration & Roadmaps | §3.8, Fig 3.7, §4.4 | **VERIFIED IMPLEMENTED** | `src/app/(app)/roadmap/page.tsx` | `app/services/agents/`, `app/services/roadmap.py` | `roadmaps` | `POST /api/v1/roadmaps/generate`, `/revise` | `test_roadmap.py` (2/2 pass) | P0 |
| **F24** | Notifications & User Preferences | §3.11, §6.2 | **VERIFIED IMPLEMENTED** | Integrated in profile & endpoints | `app/routers/notifications.py`, `app/services/notifications.py` | `notifications`, `user_engagement` | `GET/POST /api/v1/notifications`, `/read-all` | `test_notifications.py` (2/2 pass) | P2 |
| **F25** | Engagement Layer (XP, Badges, Streaks, Opt-In Leaderboard) | §3.11, §6.2 | **VERIFIED IMPLEMENTED** | Integrated in profile & endpoints | `app/services/notifications.py`, `app/routers/notifications.py` | `user_engagement` | `GET /api/v1/notifications/leaderboard` | `test_notifications.py` (2/2 pass) | P2 |
| **F26** | Functional Test Suite (T01–T19) | §4.3, Table 4.2 | **VERIFIED IMPLEMENTED** | N/A | `backend/tests/test_functional_traceability.py` | SQLite / In-memory | `pytest tests/test_functional_traceability.py` | 15/15 tests pass (T01–T16, T19) | P1 |
| **F27** | Assessment Pipeline Benchmark | §5.2, Table 5.1 | **VERIFIED IMPLEMENTED** | N/A | `backend/benchmarks/benchmark_pipeline.py` | DB / Judge0 / RAG | Standalone benchmark script | `pipeline_benchmarks.json` generated | P1 |
| **F28** | RAG Quality Evaluation Harness | §5.3, Table 5.2 | **VERIFIED IMPLEMENTED** | N/A | `backend/benchmarks/rag_eval_harness.py` | RAG / Embeddings | Standalone evaluation script | `rag_eval_results.json` generated | P1 |
| **F29** | Containerized Deployment (Docker Compose) | §4.1, Fig 4.1 | **VERIFIED IMPLEMENTED** | `frontend/Dockerfile` | `backend/Dockerfile`, `docker-compose.yml` | PostgreSQL (pgvector), Redis | `docker compose up` | Multi-stage Docker build validated | P1 |
