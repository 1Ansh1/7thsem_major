# Document 7: API and Backend Workflow Specification

> **Focus**: REST API Catalog, Endpoint Signatures, Request/Response Schemas, and Backend Architectural Patterns  
> **Source Repository Location**: `major1/backend/app/routers/`  
> **Framework**: FastAPI (Async) with Pydantic v2  

---

## 1. Architectural Concepts Explained

Before reviewing the endpoints, examiners often ask about standard backend layered architecture:

```text
Incoming HTTP Request
       │
       ▼
┌──────────────────┐
│    Middleware    │ CORS headers, timing, global exception interception
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│ Dependency Inject│ require_scopes("me"), get_db session lifecycle
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│ Endpoint Handler │ app/routers/*.py (extracts path/body, calls services)
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│  Service Layer   │ app/services/*.py (pure business logic, Judge0, RAG, Elo math)
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│ Database Models  │ app/models/*.py (SQLAlchemy 2.0 mapped relational tables)
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│ Pydantic Schemas │ app/schemas/*.py (validates request input & serializes response)
└──────────────────┘
```

1. **API Route**: The URL pattern and HTTP method path (e.g. `POST /api/v1/auth/login`).
2. **Endpoint Handler (Controller)**: The asynchronous Python function mapped to the route (e.g., `async def login(...)` in `app/routers/auth.py`). It handles HTTP concerns: reading headers, raising `HTTPException`, and returning status codes.
3. **Service Layer**: Business logic separated from HTTP details (e.g., `app/services/mastery.py:update_mastery()`). Services have no dependency on FastAPI; they accept dataclasses or DB sessions, making them pure and unit-testable.
4. **Database Model**: Python representation of a relational table (e.g., `class Question(Base)` in `app/models/content.py`).
5. **Pydantic Schema**: Data transfer object (DTO) that validates incoming request bodies and defines outgoing response JSON contracts (e.g., `ProfileOut`).
6. **Middleware**: Code that runs across every request and response before reaching route handlers (e.g., `CORSMiddleware` in `app/main.py:37`).
7. **Dependency Injection**: A technique where required resources (database sessions, authenticated user objects, configuration settings) are passed into route functions as parameters via `Depends(get_db)` or `Depends(require_scopes("me"))`. FastAPI automatically creates and tears down these dependencies per request.

---

## 2. Complete REST API Catalog (45+ Endpoints)

### 2.1 Identity & Authentication (`app/routers/auth.py`, `app/routers/users.py`)

| Endpoint | Method | Purpose | Auth / Scopes | Backend Function | Schemas (Req / Res) |
|---|---|---|---|---|---|
| `/api/v1/auth/register` | `POST` | Registers new student account | Public | `register()` | `RegisterIn` $\to$ `UserOut` |
| `/api/v1/auth/login` | `POST` | Authenticates with email & password | Public | `login()` | `LoginIn` $\to$ `TokenOut` + Cookie |
| `/api/v1/auth/refresh` | `POST` | Rotates refresh token & issues new access token | Cookie | `refresh()` | Cookie $\to$ `TokenOut` + Cookie |
| `/api/v1/auth/logout` | `POST` | Revokes active session & clears cookie | Cookie / Bearer | `logout()` | None $\to$ `{"ok": true}` |
| `/api/v1/auth/google/start`| `GET` | Initiates Google OAuth2 or mock flow | Public | `google_start()` | None $\to$ Redirect URL |
| `/api/v1/auth/google/callback`| `GET`| Handles OAuth2 callback token exchange | Public | `google_callback()` | Query code $\to$ `TokenOut` |
| `/api/v1/users/me/profile` | `GET` | Retrieves active student profile | `me` | `get_my_profile()` | None $\to$ `ProfileOut` |
| `/api/v1/users/me/profile` | `PUT` | Updates intent and academic fields | `me` | `update_my_profile()` | `ProfileIn` $\to$ `ProfileOut` |
| `/api/v1/users/me/export` | `GET` | GDPR/DPDP full learning record export | `me` | `export_my_data()` | None $\to$ JSON Data Stream |
| `/api/v1/users/me` | `DELETE`| Permanent account erasure & disk purge | `me` | `delete_my_account()` | None $\to$ `{"deleted": true}` |

---

### 2.2 Companies, Topics & Questions (`app/routers/companies.py`, `topics.py`, `questions.py`)

| Endpoint | Method | Purpose | Auth / Scopes | Backend Function | Schemas (Req / Res) |
|---|---|---|---|---|---|
| `/api/v1/companies` | `GET` | Lists all published company profiles | Public | `list_companies()` | None $\to$ `list[CompanyOut]` |
| `/api/v1/companies/{slug}` | `GET` | Retrieves company details & OA pattern | Public | `get_company()` | None $\to$ `CompanyDetailOut` |
| `/api/v1/topics` | `GET` | Lists topic taxonomy hierarchy | Public | `list_topics()` | None $\to$ `list[TopicOut]` |
| `/api/v1/topics/{id}` | `GET` | Retrieves topic and child subtopics | Public | `get_topic()` | None $\to$ `TopicDetailOut` |
| `/api/v1/questions` | `GET` | Filtered list of published questions | Public | `list_questions()` | Query $\to$ `Page[QuestionStudentView]` |
| `/api/v1/questions/{id}` | `GET` | Retrieves question with hidden tests stripped| Public | `get_question()` | None $\to$ `QuestionStudentView` |
| `/api/v1/questions` | `POST` | Creates question (manual content) | `content:write` | `create_question()` | `QuestionIn` $\to$ `QuestionOut` |

---

### 2.3 Adaptive Study Mode & Assessment Engine (`app/routers/study.py`, `tests.py`)

| Endpoint | Method | Purpose | Auth / Scopes | Backend Function | Schemas (Req / Res) |
|---|---|---|---|---|---|
| `/api/v1/study/sessions` | `POST` | Starts 8-step adaptive study session | `me` | `create_session()` | `StudyStartIn` $\to$ `StudySessionOut` |
| `/api/v1/study/sessions/{id}/answer` | `POST`| Submits answer + confidence rating | `me` | `submit_answer()` | `StudyAnswerIn` $\to$ `VerdictOut` |
| `/api/v1/study/sessions/{id}/teaching`| `GET`| Fetches RAG explanation / worked example | `me` | `get_teaching()` | Query $\to$ `TeachingBlock` |
| `/api/v1/study/sessions/{id}/complete`| `POST`| Finalizes study loop & updates mastery | `me` | `complete_session()`| None $\to$ `SessionSummaryOut` |
| `/api/v1/tests` | `GET` | Lists published assessment tests | `me` | `list_tests()` | None $\to$ `list[TestOut]` |
| `/api/v1/tests/{id}/attempts` | `POST` | Starts timed assessment attempt | `me` | `start_attempt()` | None $\to$ `AttemptStateOut` |
| `/api/v1/tests/attempts/{id}/answers` | `PUT` | Drafts question answer / flag | `me` | `save_answer()` | `SaveAnswerIn` $\to$ `{"ok": true}` |
| `/api/v1/tests/attempts/{id}/submit` | `POST` | Grades test and commits final scores | `me` | `submit_attempt()` | None $\to$ `AttemptAnalysisOut` |

---

### 2.4 Coding, Judge0 & AI Code Review (`app/routers/submissions.py`)

| Endpoint | Method | Purpose | Auth / Scopes | Backend Function | Schemas (Req / Res) |
|---|---|---|---|---|---|
| `/api/v1/submissions` | `POST` | Submits code for sandboxed execution | `me` | `create_submission()`| `SubmissionIn` $\to$ `SubmissionView` (202) |
| `/api/v1/submissions/{id}` | `GET` | Polls Judge0 execution verdict | `me` | `get_submission()` | None $\to$ `SubmissionView` |
| `/api/v1/submissions/{id}/review` | `POST`| Triggers AI Code Review (Post-Judge0) | `me` | `request_review()` | None $\to$ `CodeReviewOut` |

---

### 2.5 Readiness, Skills & Analytics (`app/routers/progress.py`)

| Endpoint | Method | Purpose | Auth / Scopes | Backend Function | Schemas (Req / Res) |
|---|---|---|---|---|---|
| `/api/v1/progress/skills` | `GET` | Fetches hierarchical skill mastery tree | `me` | `get_my_skills()` | None $\to$ `list[SkillNodeOut]` |
| `/api/v1/progress/readiness/{slug}` | `GET` | Computes Equation 3.1 Company Readiness | `me` | `get_company_readiness()`| None $\to$ `ReadinessReportOut` |
| `/api/v1/me/analytics` | `GET` | Recharts daily accuracy & histograms | `me` | `get_my_analytics()` | Query $\to$ `AnalyticsOut` |

---

### 2.6 AI Tutor, Career & Multi-Agent Subsystems (`app/routers/ai.py`, `career.py`, `interview.py`, `roadmap.py`)

| Endpoint | Method | Purpose | Auth / Scopes | Backend Function | Schemas (Req / Res) |
|---|---|---|---|---|---|
| `/api/v1/ai/tutor/explain` | `POST` | RAG Socratic concept explanation | `me` | `tutor_explain()` | `TutorExplainIn` $\to$ Envelope |
| `/api/v1/ai/tutor/hint` | `POST` | Directional non-leaking hint | `me` | `tutor_hint()` | `TutorHintIn` $\to$ Envelope |
| `/api/v1/ai/tutor/evaluate` | `POST` | Evaluates student written answer | `me` | `tutor_evaluate()` | `TutorEvalIn` $\to$ Envelope |
| `/api/v1/ai/stats` | `GET` | AI token costs & latency observability | `admin:panel` | `ai_stats()` | None $\to$ `AIStatsOut` |
| `/api/v1/career/resume` | `POST` | Uploads PDF resume for async parsing | `me` | `upload_resume()` | Multipart $\to$ `ResumeOut` |
| `/api/v1/career/gap` | `GET` | Deterministic resume vs JD skill match | `me` | `get_skill_gap()` | Query $\to$ `SkillGapOut` |
| `/api/v1/interviews` | `POST` | Starts conversational mock interview | `me` | `start_interview()` | `InterviewStartIn` $\to$ `InterviewView` |
| `/api/v1/interviews/{id}/turn`| `POST` | Submits student interview turn response | `me` | `submit_turn()` | `TurnIn` $\to$ `InterviewView` |
| `/api/v1/interviews/{id}/finish`| `POST`| Grades 5-dimension rubric & commits score | `me` | `finish_interview()`| None $\to$ `InterviewView` |
| `/api/v1/roadmaps/active` | `GET` | Fetches active personalized roadmap | `me` | `get_active_roadmap()`| None $\to$ `RoadmapView` |
| `/api/v1/roadmaps/generate` | `POST` | Synthesizes daily company schedule | `me` | `generate_roadmap()` | `RoadmapGenerateIn` $\to$ `RoadmapView` |
| `/api/v1/roadmaps/revise` | `POST` | Dynamically adapts plan on test failure | `me` | `revise_roadmap()` | `RoadmapReviseIn` $\to$ `RoadmapView` |
| `/api/v1/notifications` | `GET` | Lists smart reminders & alerts | `me` | `list_notifications()`| None $\to$ `list[NotificationOut]` |
| `/api/v1/notifications/leaderboard`| `GET`| Opt-in student XP leaderboard | `me` | `get_leaderboard()` | None $\to$ `list[LeaderboardEntry]` |

---

## 3. End-to-End Tracing of Five Major Requests

### Request Trace 1: Code Submission to Sandboxed Execution
```text
1. Client action: User clicks "Submit Code" in Monaco Editor.
2. HTTP Call: POST /api/v1/submissions
   Body: {"question_id": 4, "language": "cpp", "code": "#include <iostream>...", "mode": "submit"}
3. Endpoint: app/routers/submissions.py:create_submission()
4. Dependency: require_scopes("me") validates student JWT.
5. Service: app/services/judging.py:submit_code()
   • Inserts Submission record with status="queued".
   • Returns HTTP 202 Accepted with SubmissionView.
6. Background Queue: jobs.enqueue("judge_submission", sub_id=submission.id)
   • Calls app/services/judge.py:execute_batch()
   • Sends batch to Judge0 container: POST https://ce.judge0.com/submissions/batch
7. Polling: Client polls GET /api/v1/submissions/{id} every 1.5 seconds.
8. Judge0 Finishes: Returns status_id=3 (Accepted), time=0.04s, memory=12.4MB.
9. DB Update: verdicts row updated; submission.verdict committed.
10. Mastery Trigger: Successful submission triggers update_mastery(skill, Evidence(correct=True)).
11. Client Update: Monaco Editor changes status badge from "Queued..." to "Accepted — 12/12 Passed".
```

### Request Trace 2: Adaptive Roadmap Dynamic Revision
```text
1. Trigger: Student scores 35% on Graphs test (below 50% threshold).
2. HTTP Call: POST /api/v1/roadmaps/revise
   Body: {"struggled_topic": "Graphs", "performance_score": 35.0}
3. Endpoint: app/routers/roadmap.py:revise_plan()
4. Service: app/services/roadmap.py:revise_roadmap()
5. Multi-Agent Delegation: Calls orchestrator.py:recommendation_agent_revise_roadmap()
6. AI Synthesis: Gemini Strong receives original schedule and struggle context.
   • Generates RoadmapRevisionOut: extends Graphs revision by 2 days, postpones Dynamic Programming.
7. DB Commit:
   • Increments roadmap.version from 1 to 2.
   • Updates roadmap.plan with revised daily schedule.
   • Appends reason to revision_history JSON.
   • Inserts record in recommendations table.
8. Response: Returns revised RoadmapView with HTTP 200 OK.
9. Client Update: Frontend /roadmap page highlights revised milestone cards with an info banner:
   "Plan dynamically adapted: 2 days added for remedial Graph practice."
```

### Request Trace 3: RAG AI Tutor Directional Hinting
```text
1. Client action: Student is stuck on Question 15 and clicks "Need a Hint".
2. HTTP Call: POST /api/v1/ai/tutor/hint
   Body: {"question_id": 15, "attempt_text": "I tried using a nested loop..."}
3. Endpoint: app/routers/ai.py:tutor_hint()
4. Service: app/services/tutor.py:hint()
5. Guardrails:
   • Extracts question answer into forbidden_fragments list.
   • Searches RAG for top 3 concept chunks.
   • Prompts Gemini with HintOut contract forbidding answer reveal.
6. Anti-Leak Filter: Output scanned against forbidden fragments.
   • If leaked: discarded and retried with stricter negative prompt.
   • If clean: passes check_citations() guardrail.
7. DB Commit: Commits token usage and latency into ai_traces table.
8. Response: Returns {"mode": "hint", "data": {"hint": "Consider tracking visited nodes in a set...", "next_step": "..."}, "citations": [...], "grounded": true}.
9. Client Update: Tutor sidebar renders directional hint without giving away the solution.
```

### Request Trace 4: Mock Interview Turn & Rubric Evaluation
```text
1. Client action: Student clicks "Finish Interview" after Turn 4.
2. HTTP Call: POST /api/v1/interviews/8/finish
3. Endpoint: app/routers/interview.py:finish_session()
4. Service: app/services/interview.py:finish_interview()
5. Verification: Confirms at least 1 student response exists in transcript.
6. AI Evaluation: Calls Gemini Strong with full transcript and InterviewEvaluationOut schema.
   • Evaluates 5 dimensions (Technical, Problem Solving, Communication, Confidence, Concept Accuracy) on 1-10 scale.
7. Math Scaling:
   • Computes avg_score_10 = sum(5 dims) / 5.0.
   • Computes overall_score = avg_score_10 * 10.0 (0–100 scale).
8. DB Commit:
   • UPDATE interviews SET status='completed', scores=?, report=?, ended_at=NOW().
9. Dynamic Feedback Loop: Equation 3.1 in readiness_data.py now incorporates this 0–100 interview score.
10. Client Update: Frontend renders 5-dimension radar chart and detailed feedback report.
```

### Request Trace 5: Student Data Portability Export
```text
1. Client action: Student clicks "Export My Learning Record (JSON)" in Profile.
2. HTTP Call: GET /api/v1/users/me/export
3. Endpoint: app/routers/users.py:export_my_data()
4. Dependency: require_scopes("me") verifies user identity.
5. Aggregation: Executes async queries across 8 tables:
   • users, profiles, mastery, attempts, submissions, readiness_scores, resumes, interviews, roadmaps.
6. Serialization: Formats records into an auditable GDPR Article 20 / DPDP Act compliant JSON payload.
7. Response: Returns JSON stream with header Content-Disposition: attachment; filename="preppath_student_data_4.json".
8. Client Action: Browser triggers automatic file download of the complete personal record.
```
