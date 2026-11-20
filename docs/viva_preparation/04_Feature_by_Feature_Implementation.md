# Document 4: Feature-by-Feature Implementation & Code Tracing

> **Status**: Comprehensive Engineering Walkthrough & Codebase Traceability  
> **Applicable Project**: PrepPath — AI-Powered Adaptive Placement Preparation Platform  
> **Source Repository Location**: `major1/`  
> **Explanation Standard**: Level 1 (Beginner Analogy) · Level 2 (Technical Deep Dive) · Level 3 (Spoken Viva Defense)  

---

## Feature Matrix & Implementation Status

| Feature ID | Feature Name | Codebase Status | Frontend Files | Backend Files | Key Endpoints / Services |
|---|---|---|---|---|---|
| **F01** | Student Authentication & RBAC | **FULLY IMPLEMENTED** | `src/lib/auth.tsx`, `src/lib/api.ts`, `src/app/login/`, `src/app/register/` | `app/routers/auth.py`, `app/core/security.py`, `app/models/identity.py` | `POST /api/v1/auth/register`, `/login`, `/refresh`, `/logout` |
| **F02** | Student Profile & Targets | **FULLY IMPLEMENTED** | `src/app/(app)/profile/page.tsx` | `app/routers/users.py`, `app/models/identity.py` | `GET/PUT /api/v1/users/me/profile` |
| **F03** | Company Intelligence Layer | **FULLY IMPLEMENTED** | `src/app/(app)/companies/page.tsx`, `[slug]/page.tsx` | `app/routers/companies.py`, `app/models/domain.py` | `GET /api/v1/companies`, `GET /companies/{slug}` |
| **F04** | Question Bank & Taxonomy | **FULLY IMPLEMENTED** | `src/app/(app)/questions/page.tsx`, `[id]/page.tsx` | `app/routers/questions.py`, `topics.py`, `models/content.py` | `GET /api/v1/questions`, `GET /topics` |
| **F05** | Adaptive Study Mode | **FULLY IMPLEMENTED** | `src/app/(app)/study/[id]/page.tsx` | `app/routers/study.py`, `app/services/content.py` | `POST /api/v1/study/sessions`, `/answer`, `/complete` |
| **F06** | Hierarchical Skill Graph | **FULLY IMPLEMENTED** | `src/app/(app)/skills/page.tsx` | `app/services/skill_graph.py`, `app/services/mastery.py` | `GET /api/v1/progress/skills` |
| **F07** | Deterministic Mastery Updates | **FULLY IMPLEMENTED** | Rendered in Mastery bars across platform | `app/services/mastery.py` | Pure service: `update_mastery()`, `target_difficulty()` |
| **F08** | Test Mode & Assessment Engine | **FULLY IMPLEMENTED** | `src/app/(app)/tests/attempt/[id]/page.tsx` | `app/routers/tests.py`, `app/services/grading.py` | `POST /api/v1/tests/{id}/attempts`, `/submit` |
| **F09** | Monaco Editor & Judge0 Pipeline | **FULLY IMPLEMENTED** | `CodeWorkbench.tsx`, `CodeEditor.tsx` | `app/services/judge.py`, `judging.py`, `submissions.py` | `POST /api/v1/submissions`, `GET /submissions/{id}` |
| **F10** | Company Readiness Score (Eq 3.1)| **FULLY IMPLEMENTED** | `src/app/(app)/readiness/[slug]/page.tsx` | `app/services/readiness.py`, `readiness_data.py` | `GET /api/v1/progress/readiness/{slug}` |
| **F11** | Student Analytics Dashboard | **FULLY IMPLEMENTED** | `src/app/(app)/analytics/page.tsx` | `app/routers/progress.py`, `app/models/domain.py` | `GET /api/v1/me/analytics?days=30` |
| **F12** | RAG Ingestion & Vector Search | **FULLY IMPLEMENTED** | `src/app/(app)/admin/knowledge/page.tsx` | `app/routers/kb.py`, `app/services/rag.py` | `POST /api/v1/kb/documents`, `POST /upload` |
| **F13** | RAG-Based AI Tutor (6 Modes) | **FULLY IMPLEMENTED** | `src/app/(app)/tutor/page.tsx` | `app/routers/ai.py`, `app/services/tutor.py` | `POST /api/v1/ai/tutor/{explain,hint,...}` |
| **F14** | AI Code Review | **FULLY IMPLEMENTED** | `src/components/CodeReviewPanel.tsx` | `app/services/code_review.py` | `POST /api/v1/submissions/{id}/review` |
| **F15** | Resume & JD Gap Analysis | **FULLY IMPLEMENTED** | `src/app/(app)/career/page.tsx` | `app/routers/career.py`, `app/services/career.py` | `POST /api/v1/career/resume`, `GET /gap` |
| **F16** | Interactive Mock Interview | **FULLY IMPLEMENTED** | `src/app/(app)/interview/page.tsx` | `app/routers/interview.py`, `app/services/interview.py` | `POST /api/v1/interviews`, `/turn`, `/finish` |
| **F17** | 7-Agent Dynamic Roadmaps | **FULLY IMPLEMENTED** | `src/app/(app)/roadmap/page.tsx` | `app/services/agents/orchestrator.py`, `roadmap.py` | `POST /api/v1/roadmaps/generate`, `/revise` |
| **F18** | Admin & AI Guardrails | **FULLY IMPLEMENTED** | `src/app/(app)/admin/ai/`, `admin/review/` | `app/services/guardrails.py`, `app/services/llm.py` | `GET /api/v1/ai/stats`, `POST /questions/generate` |
| **F19** | Notifications & Engagement | **FULLY IMPLEMENTED** | Integrated in profile & header console | `app/routers/notifications.py`, `services/notifications.py` | `GET/POST /api/v1/notifications`, `/leaderboard` |
| **F20** | Data Portability & Erasure | **FULLY IMPLEMENTED** | `src/app/(app)/profile/page.tsx` | `app/routers/users.py`, `app/models/identity.py` | `GET /api/v1/users/me/export`, `DELETE /users/me` |

---

## Module 1: Authentication, Authorization & RBAC

### Level 1: Beginner Metaphor
Think of authentication like an airport security checkpoint. When you arrive with your passport (login credentials), the agent verifies your identity and hands you two items:
1. A **boarding pass** (the 15-minute Access Token): You keep it in your hand (in memory). It lets you walk through gates quickly. If you drop it, it expires in minutes anyway.
2. A **claim check slip** (the Refresh Token): Placed inside a sealed tamper-proof security pouch (an `httpOnly` cookie). You cannot read it or alter it. When your boarding pass expires, you show the sealed slip to get a new pass without entering your full passport credentials again. If someone tries to photocopy your claim slip, the airline cancels your entire travel ticket (family reuse revocation).

### Level 2: Technical Deep Dive
- **Implementation Location**:
  - Backend: `backend/app/routers/auth.py`, `backend/app/core/security.py`, `backend/app/core/deps.py`, `backend/app/models/identity.py`
  - Frontend: `frontend/src/lib/api.ts`, `frontend/src/lib/auth.tsx`, `frontend/src/app/login/page.tsx`
- **Password Hashing**: Implemented in `app/core/security.py:hash_password()` using **Argon2id** (the winner of the Password Hashing Competition), offering superior resistance against GPU and ASIC brute-force attacks compared to legacy bcrypt or SHA-256.
- **Token Architecture**:
  - **Access Token**: Short-lived (15 minutes), signed using HMAC-SHA256 (`HS256`). Stored **strictly in JavaScript memory** (`let accessToken: string | null = null;` in `src/lib/api.ts`). Never persisted to `localStorage` or `sessionStorage` to eliminate Cross-Site Scripting (XSS) token theft.
  - **Refresh Token**: Long-lived (14 days), cryptographically random string stored as an SHA-256 hash in the `sessions` table (`app/models/identity.py:UserSession`). Transmitted as an `httpOnly`, `SameSite=Lax`, path-scoped (`/api/v1/auth`) cookie.
- **Refresh Token Rotation & Theft Detection**:
  - Each session belongs to a `family_id` (`app/models/identity.py:43`).
  - When `/api/v1/auth/refresh` is called, the old session is marked `replaced_by_id = new_id`.
  - If a revoked or already-replaced refresh token is ever presented again (indicating that an attacker intercepted a previously used token), `app/routers/auth.py` automatically revokes the **entire session family**, immediately invalidating all active tokens for that user.
- **Role-Based Access Control (RBAC)**:
  - Three distinct roles: `student` (default), `content_manager`, and `admin`.
  - Roles map to specific token scopes (`me`, `content:read`, `content:write`, `admin:panel`, `users:manage`).
  - Protected endpoints inject `user: User = Depends(require_scopes("admin:panel"))` (`app/core/deps.py:48`).
- **Frontend Auto-Refresh Wrapper**:
  - In `src/lib/api.ts`, if an API call receives an HTTP 401 response, it initiates `refreshSession()`.
  - If refresh succeeds, it transparently replays the original request.
  - If multiple concurrent requests trigger 401s, `refreshing: Promise<boolean>` deduplicates calls so only one refresh POST is dispatched.

### Level 3: Spoken Viva Defense & Follow-Up
> **How to speak in viva**:  
> *"We implemented a dual-token authentication system using Argon2id password hashing and JWT rotation. To protect student sessions from Cross-Site Scripting (XSS), the access token is stored strictly in memory with a 15-minute lifespan. The refresh token is an httpOnly cookie scoped exclusively to `/api/v1/auth`. Furthermore, we implemented token rotation with family-based reuse detection: if an old refresh token is reused, the backend assumes a token compromise and revokes the entire session chain."*

- **Examiner Follow-Up Question**: *"Why not just store the JWT in `localStorage`?"*  
  **Your Answer**: *"Any third-party script, browser extension, or XSS vulnerability can read `localStorage.getItem('token')`. By keeping the access token in module memory and storing the refresh token in an `httpOnly` cookie, JavaScript cannot read the token, closing the primary attack vector for session hijacking."*

---

## Module 2: Student Profile & Personalization

### Level 1: Beginner Metaphor
Your profile is like a medical chart at a hospital. When you register, you record your background (college, branch, graduation year) and your career goals (target company: Amazon, role: SDE). As you practice, the chart automatically records your vital signs (DSA score, CS fundamentals score, study streak). The rest of the platform checks this chart before prescribing your next study plan.

### Level 2: Technical Deep Dive
- **Implementation Location**:
  - Backend: `backend/app/models/identity.py` (`Profile` class, lines 52–79), `backend/app/routers/users.py` (`get_my_profile()`, `update_my_profile()`)
  - Frontend: `frontend/src/app/(app)/profile/page.tsx`
- **Database Schema**:
  - Linked to `users` via a 1:1 relationship with `cascade="all, delete-orphan"`.
  - Academic metadata: `college`, `branch`, `graduation_year`.
  - Intent metadata: `target_role`, `target_company_ids` (stored as JSON integer array).
  - Measured competence: `dsa_score`, `csf_score`, `aptitude_score`, `coding_score` (nullable floats populated by assessment engines).
  - Behavioral metrics: `study_streak` (integer), `last_active_on` (Date), `topics_completed`, `weak_topics` (JSON array of strings), `preferred_language` (`python`, `cpp`, `java`, `javascript`).
- **Completeness Calculation**: Dynamically calculated on profile retrieval (`app/routers/users.py:32`):
  $$\text{Completeness} = \text{round}\left(100 \times \frac{\sum [f \neq \text{None}]}{\text{Total Fields}}\right)$$
- **Impact on Preparation**:
  - The `preferred_language` pre-configures Monaco Editor templates.
  - The `target_company_ids` filter question recommendations and drive Company Readiness comparisons.

### Level 3: Spoken Viva Defense & Follow-Up
> **How to speak in viva**:  
> *"The Student Profile anchors every recommendation on the platform. It maintains a clean separation between user-editable intent (target companies, target role, language) and system-computed competence (DSA score, streak, weak topics). These competence fields cannot be edited by the student; they are updated strictly through verified attempts and Judge0 verdicts."*

- **Examiner Follow-Up Question**: *"How do you handle the cold-start problem when a new student has no performance scores?"*  
  **Your Answer**: *"Competence scores initialize to `None`. The UI displays an unmeasured badge, and the readiness engine reports 0.0 with an explicit flag `available: false` and detail note `'No DSA practice yet'`. We never invent or hallucinate default baseline numbers."*

---

## Module 3: Company Intelligence Layer

### Level 1: Beginner Metaphor
Imagine studying for an exam where every company tests completely different subjects. Company Intelligence acts like an experienced senior's placement diary: it records that Amazon heavily emphasizes Binary Trees, Graphs, and OOP (45%), whereas TCS focuses more on Quantitative Aptitude and Core Fundamentals.

### Level 2: Technical Deep Dive
- **Implementation Location**:
  - Backend: `backend/app/models/domain.py` (`Company` class, lines 27–40), `backend/app/routers/companies.py`
  - Frontend: `frontend/src/app/(app)/companies/page.tsx`, `frontend/src/app/(app)/companies/[slug]/page.tsx`
- **Data Model**:
  - `name` (String 120, unique), `slug` (String 140, index), `description` (Text).
  - `skill_weights`: JSON dictionary mapping domains to percentages summing to 100:
    ```json
    {"dsa": 45, "oop": 15, "dbms": 15, "os": 10, "aptitude": 10, "hr": 5}
    ```
  - `oa_pattern`: JSON dictionary defining Online Assessment structures:
    ```json
    {"coding_questions": 2, "mcqs": 20, "duration_minutes": 90, "difficulty": "hard", 
     "frequent_topics": ["Arrays", "Trees", "Graphs", "Dynamic Programming"]}
    ```
  - `readiness_weights`: Optional override of Equation 3.1 default weights.
- **Mandatory Ethical Disclaimer**:
  - Enforced in `app/schemas/common.py` and returned on all company endpoints:
    `"Observed historical preparation patterns — not official recruiter specifications"`
  - Displayed prominently in the frontend UI to prevent misleading students into believing PrepPath has an official corporate partnership.

### Level 3: Spoken Viva Defense & Follow-Up
> **How to speak in viva**:  
> *"Our Company Intelligence layer formalizes the syllabus differences across hiring organizations. Rather than generic practice, each company profile defines expected skill distributions, OA test durations, and frequently tested topic tags. To maintain academic and legal integrity, every company endpoint injects a mandatory disclaimer that these reflect observed historical patterns rather than official recruiter specifications."*

- **Examiner Follow-Up Question**: *"Where did the data for Amazon, TCS, and Microsoft come from?"*  
  **Your Answer**: *"In our seed dataset (`app/seed_content.py`), company profiles were curated from publicly published placement interview archives, student interview debriefs, and campus hiring patterns commonly observed at JIIT."*

---

## Module 4: Question Bank & Topic Taxonomy

### Level 1: Beginner Metaphor
A library doesn't just pile books on the floor; it organizes them by section, shelf, and subject. Our Question Bank groups every problem into a 6-domain hierarchy (DSA, DBMS, OS, CN, OOP, Aptitude), tags them with difficulty and company associations, and keeps confidential test cases locked in a vault away from the student.

### Level 2: Technical Deep Dive
- **Implementation Location**:
  - Backend: `backend/app/models/content.py` (`Topic`, `Question`, `TestQuestion`, lines 15–75), `backend/app/routers/questions.py`, `backend/app/routers/topics.py`
  - Frontend: `frontend/src/app/(app)/questions/page.tsx`, `frontend/src/app/(app)/questions/[id]/page.tsx`
- **Topic Hierarchy**:
  - Self-referencing table via `parent_id` (`ForeignKey("topics.id")`).
  - Six root areas: `DSA`, `DBMS`, `OS`, `CN`, `OOP`, `Aptitude`.
  - Subtopics inherit the area (e.g., `Trees` $\to$ `Binary Search Trees` under `DSA`).
- **Question Types Supported**:
  - `mcq` (Single correct answer)
  - `multi_select` (Multiple correct options)
  - `numerical` (Exact or range-based integer/float)
  - `coding` (Multi-language automated Judge0 evaluation)
  - `sql` (Database query execution on SQLite/PostgreSQL)
  - `output_prediction`, `debugging`, `theory`
- **Security & Answer Suppression**:
  - In `app/routers/questions.py`, student endpoints serialize questions through `QuestionStudentView`.
  - The `answer`, `explanation`, and `meta["hidden_tests"]` fields are **strictly removed** on the backend before the JSON response is dispatched.
  - Students only receive visible sample test cases (`meta["samples"]`).

### Level 3: Spoken Viva Defense & Follow-Up
> **How to speak in viva**:  
> *"Our Question Bank models a rich taxonomy supporting 8 distinct question types. Crucially, the student API endpoints enforce strict field-level redaction: confidential answer keys, explanations, and hidden test cases are stripped on the server side, ensuring that students cannot inspect answers using browser Developer Tools."*

- **Examiner Follow-Up Question**: *"How do many-to-many relationships work between questions and companies?"*  
  **Your Answer**: *"We use a dedicated association table `question_companies` with composite primary keys (`question_id`, `company_id`) and cascading foreign keys (`app/models/content.py:6-12`). This allows a single coding problem, such as 'Two Sum', to be associated with Amazon, TCS, and Microsoft simultaneously."*

---

## Module 5: Adaptive Study Mode

### Level 1: Beginner Metaphor
Imagine a private human tutor sitting beside you. The tutor doesn't just hand you a 50-page chapter. First, they ask you a quick diagnostic question to see what you already know. When you answer, they explain the concept step-by-step, walk you through a real worked example with numbered reasoning, and give you a follow-up mini-quiz. If you do well, they increase the difficulty; if you struggle, they slow down.

### Level 2: Technical Deep Dive
- **Implementation Location**:
  - Backend: `backend/app/routers/study.py` (375 lines), `backend/app/services/content.py`, `backend/app/services/tutor.py`
  - Frontend: `frontend/src/app/(app)/study/[id]/page.tsx`
- **The 8-Step Interactive Loop**:
  1. **Topic Selection**: Student initiates session for a topic (`POST /api/v1/study/sessions`).
  2. **Diagnostic Question**: Backend inspects `mastery` table and selects question via `target_difficulty(mastery_score)`.
  3. **Response & Confidence**: Student submits answer and self-reported confidence (1–5 scale) (`POST /answer`).
  4. **Immediate Verdict**: Deterministic auto-grading or Judge0 evaluation returns verdict.
  5. **RAG Conceptual Explanation**: Student requests explanation (`GET /teaching?kind=explanation`); RAG retrieves top 4 chunks and Gemini synthesizes core concepts with citations.
  6. **Worked Example**: Student requests worked example (`GET /teaching?kind=worked_example`); AI synthesizes a problem with numbered reasoning steps and final answer.
  7. **Follow-Up Mini Quiz**: Adaptive follow-up question tests the newly explained concept.
  8. **Session Completion**: Finalizes session (`POST /complete`); triggers deterministic mastery update.
- **Workflow Diagram**: Defined in [`Study_Mode_Flow.mmd`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/diagrams/Study_Mode_Flow.mmd).

### Level 3: Spoken Viva Defense & Follow-Up
> **How to speak in viva**:  
> *"Adaptive Study Mode is not a static quiz. It is an 8-step pedagogical loop that pairs diagnostic assessment with RAG-grounded teaching. Unlike generic platforms that simply show an answer key upon failure, PrepPath dynamically serves grounded explanations and step-by-step worked examples before updating the student's mastery score based on both accuracy and self-reported confidence."*

- **Examiner Follow-Up Question**: *"What happens if there are no RAG documents for a selected topic?"*  
  **Your Answer**: *"The tutor service refuses to call the LLM (`app/services/tutor.py:140`). Instead, it returns an explicit ungrounded refusal message: `'The course knowledge base doesn't cover this yet, so I won't guess.'` This completely eliminates hallucination on uncovered topics."*

---

## Module 6: Hierarchical Skill Graph & Learner Model

### Level 1: Beginner Metaphor
Think of skills as a family tree. Under the parent "Data Structures and Algorithms", you have children like "Trees", and under Trees, you have "Binary Search Trees" and "AVL Trees". If a student fails a test on AVL Trees, the system doesn't assume they are bad at everything; it pinpoints the exact leaf node in the tree and updates their mastery locally, while also rolling up their broader domain competence.

### Level 2: Technical Deep Dive
- **Implementation Location**:
  - Backend: `backend/app/services/skill_graph.py`, `backend/app/services/mastery.py`, `backend/app/models/domain.py` (`Mastery` class)
  - Frontend: `frontend/src/app/(app)/skills/page.tsx`
- **Data Model**:
  - `skills` table contains hierarchical nodes (`parent_id` references `skills.id`).
  - `mastery` table tracks per-student state:
    `mastery_score` (0.0 to 100.0), `attempt_count`, `correct_count`, `accuracy`, `average_time_ms`, `difficulty`, `confidence`, `last_attempt`.
- **Hierarchical Rollup (`app/services/skill_graph.py:area_mastery()`)**:
  - Leaf nodes track direct attempt evidence.
  - Parent nodes compute weighted averages of their children:
    $$\text{Parent Mastery} = \frac{\sum (\text{Child Mastery} \times \text{Child Weight})}{\sum \text{Child Weights}}$$
  - Unpracticed subtrees are clearly reported as unmeasured rather than zeroed out.

### Level 3: Spoken Viva Defense & Follow-Up
> **How to speak in viva**:  
> *"We model student competence using a Hierarchical Skill Graph rather than a flat list. This allows the platform to understand granular weaknesses (such as struggling specifically with Dijkstra's algorithm) while aggregating these scores up the tree to compute overall domain mastery across DSA, DBMS, OS, Computer Networks, and OOP."*

- **Examiner Follow-Up Question**: *"Do you use a Graph Neural Network (GNN) here?"*  
  **Your Answer**: *"No. A GNN would be an uninterpretable, high-overhead black box for an undergraduate learner model. We deliberately chose a deterministic, tree-structured graph traversal algorithm with auditable Bayesian updates, ensuring that every score change can be mathematically traced."*

---

## Module 7: Deterministic Mastery Update Algorithm

### Level 1: Beginner Metaphor
Think of an Elo rating in chess. If a grandmaster beats a beginner, their rating increases by only 1 point because the win was expected. But if a beginner beats a grandmaster, their rating jumps up significantly. Similarly, if you solve a Hard question quickly, your mastery surges; if you get an Easy question wrong while claiming high confidence, your score drops sharply because of a dangerous misconception.

### Level 2: Technical Deep Dive
- **Implementation Location**: `backend/app/services/mastery.py` (lines 1–102)
- **Mathematical Update Formula**:
  $$\Delta = \text{clamp}\left(\text{lr} \times w \times (\text{target} - \text{mastery}), -15.0, +15.0\right)$$
  - Target: $\text{target} = 100.0$ if correct, $0.0$ if incorrect.
  - Learning Rate Decay:
    $$\text{lr} = \max\left(0.15, \frac{1}{\text{attempt\_count} + 2}\right)$$
    *Moves fast during early attempts (exploration) and stabilizes as evidence accumulates.*
  - Difficulty Weights ($d$): `easy` = 0.7, `medium` = 1.0, `hard` = 1.3.
  - Correct Answer Weight ($w_{\text{correct}}$):
    $$w = d \times \text{clamp}\left(1.2 - 0.2 \times \frac{\text{time\_ms}}{\text{expected\_ms}}, 0.8, 1.1\right) \times (0.85 + 0.15 \times \text{confidence})$$
  - Incorrect Answer Weight ($w_{\text{wrong}}$):
    $$w = (2.0 - d) \times (1.0 + 0.3 \times \text{confidence})$$
    *(Missing an easy question hurts more: $2.0 - 0.7 = 1.3$. Missing hard question: $2.0 - 1.3 = 0.7$. High confidence on wrong answer triggers a 30% misconception penalty!)*
- **Moving Averages**:
  - Exponential moving average of solve time: $\text{avg\_time} = \text{avg\_time} \times 0.8 + \text{time\_ms} \times 0.2$.
  - Running confidence mean: $\text{conf} = \text{conf} \times 0.7 + \text{new\_conf} \times 0.3$.

### Level 3: Spoken Viva Defense & Follow-Up
> **How to speak in viva**:  
> *"Our mastery update function is completely pure and deterministic—no I/O, no randomness, and no LLM involvement. It adapts Bayesian learning rate decay with an Elo-inspired difficulty weighting. It uniquely incorporates both time efficiency and self-reported confidence: answering an easy question incorrectly with high confidence penalizes mastery heavily because it signals a fundamental misconception."*

- **Examiner Follow-Up Question**: *"Why clamp the delta to $\pm 15.0$ points?"*  
  **Your Answer**: *"To prevent score volatility. A single lucky guess or a single accidental misclick should never swing a student's mastery from 20% to 80% overnight. Clamping ensures steady, evidence-based progression."*

---

## Module 8: Test Mode & Assessment Engine

### Level 1: Beginner Metaphor
Test Mode is like the official online assessment (OA) on exam day. You sit at a computer with a countdown timer. You cannot pause the clock. If your time runs out, the system automatically submits whatever answers you have marked so far and grades them strictly according to the exam rules (including negative marking).

### Level 2: Technical Deep Dive
- **Implementation Location**:
  - Backend: `backend/app/routers/tests.py` (520 lines), `backend/app/services/grading.py`
  - Frontend: `frontend/src/app/(app)/tests/page.tsx`, `frontend/src/app/(app)/tests/attempt/[id]/page.tsx`
- **Server-Enforced Timing**:
  - The server records `started_at = utcnow()`.
  - The deadline is strictly enforced on the server: `deadline = started_at + duration_seconds`.
  - Client-side countdown is cosmetic; if a student attempts to submit after the server deadline, the backend automatically seals the attempt and grades existing draft answers.
- **Section Navigation & State**:
  - Attempt state stores question responses in a JSON blob: `state["responses"][qid] = answer`.
  - Supports question flagging (`flagged: [qid1, qid2]`) and section-based navigation.
- **Deterministic Grading (`app/services/grading.py:grade_attempt()`)**:
  - Applies section marks (e.g. +2.0 marks for MCQ, +5.0 for coding).
  - Applies negative marking penalties if configured on the test (e.g. $-0.5$ marks for wrong MCQ).
  - Scores are normalized to percentage $[0, 100]$ and committed to the `attempts` table.
  - Automatically triggers skill graph mastery updates for all evaluated questions.

### Level 3: Spoken Viva Defense & Follow-Up
> **How to speak in viva**:  
> *"Our Assessment Engine provides a rigorous simulation of corporate online assessments. It features server-enforced timeouts, negative marking, randomized question ordering, and auto-submission preservation. When time expires, partial responses are never discarded; they are sealed, graded, and fed into the mastery and readiness engines."*

- **Examiner Follow-Up Question**: *"What prevents a student from tampering with the timer in their browser?"*  
  **Your Answer**: *"The frontend timer is purely an interface aid. The true deadline is computed on the backend as `started_at + duration_seconds`. Any answer submitted after this timestamp is rejected or auto-graded by the server."*

---

## Module 9: Monaco Code Editor & Sandboxed Judge0 Pipeline

### Level 1: Beginner Metaphor
Imagine a chemistry lab where dangerous experiments must be conducted. You don't perform them on your study desk. You place the chemicals inside an airtight, blast-proof glass chamber (the Judge0 sandbox). You send in the instructions, watch the reaction from behind the glass, and write down the result (Accepted or Explosion).

### Level 2: Technical Deep Dive
- **Implementation Location**:
  - Backend: `backend/app/services/judge.py`, `backend/app/services/judging.py`, `backend/app/routers/submissions.py`
  - Frontend: `frontend/src/components/CodeWorkbench.tsx`, `frontend/src/components/CodeEditor.tsx`, `frontend/src/lib/judge.ts`
- **Supported Languages & Judge0 IDs**:
  - Python 3.13 (`id: 109`)
  - C++ GCC 14 (`id: 105`)
  - Java 13 (`id: 62`)
  - JavaScript Node 22 (`id: 102`)
  - SQL SQLite 3 (`id: 82`)
- **Execution Pipeline**:
  ```text
  1. Student Clicks "Submit" in Monaco Editor
  2. POST /api/v1/submissions {question_id, code, language, mode: "submit"}
  3. Backend inserts Submission row (status: "queued") -> Returns HTTP 202 Accepted
  4. Background worker dispatches batch to Judge0 CE: POST /submissions/batch
     • Base64 encoded code, stdin, expected_output, limits (cpu: 2s, mem: 128MB)
  5. Background worker polls Judge0 status: GET /submissions/batch?tokens=...
  6. Judge0 returns status_ids (3=Accepted, 4=WA, 5=TLE, 6=CE, 7-12=RE)
  7. Backend aggregates case results prioritizing fundamental failures:
     CE > RE > TLE > WRONG > INTERNAL > ACCEPTED
  8. Verdict written to verdicts table; frontend polling renders verdict badge.
  ```
- **Hidden Test Case Isolation**:
  - Hidden test inputs and expected outputs are stored in `questions.meta["hidden_tests"]`.
  - When submitting code, the backend sends hidden tests directly to Judge0.
  - The client receives only case pass/fail counts (e.g. `12 / 12 tests passed`), runtime in seconds, and memory in MB. Hidden inputs are **never sent to the client browser**.

### Level 3: Spoken Viva Defense & Follow-Up
> **How to speak in viva**:  
> *"Code evaluation in PrepPath is completely isolated from the application server. We dispatch multi-test batches to an asynchronous Judge0 CE sandbox running inside Linux cgroups. Test cases are executed against standard time (2.0s) and memory (128MB) limits. Crucially, hidden test cases are transmitted strictly between our backend and Judge0; they are never exposed to the client."*

- **Examiner Follow-Up Question**: *"What happens if a student writes an infinite loop or malicious code like `import os; os.system('rm -rf /')`?"*  
  **Your Answer**: *"First, our application server never executes student code. Second, inside Judge0, the code runs in an unprivileged, non-root sandbox with strict CPU timeouts (causing a Time Limit Exceeded verdict after 2 seconds) and seccomp system-call filtering that blocks access to the host filesystem and network sockets."*

---

## Module 10: Company Readiness Score (Equation 3.1)

### Level 1: Beginner Metaphor
Imagine calculating your semester grade. Your professors don't just look at one exam. They use a published formula: 25% Midterm, 25% Final, 20% Lab, 15% Quizzes, 10% Viva, and 10% Attendance. The Company Readiness Score works the same way: it is an auditable weighted sum of your DSA, CS fundamentals, Coding solve speed, Aptitude accuracy, Mock interview scores, and Preparation consistency.

### Level 2: Technical Deep Dive
- **Implementation Location**:
  - Math Definition: `backend/app/services/readiness.py` (lines 1–116)
  - Data Gathering: `backend/app/services/readiness_data.py` (lines 1–241)
  - Frontend Display: `frontend/src/app/(app)/readiness/[slug]/page.tsx`
- **Equation 3.1**:
  $$\text{CRS} = 0.25 \cdot \text{DSA} + 0.20 \cdot \text{CSF} + 0.20 \cdot \text{Coding} + 0.15 \cdot \text{Aptitude} + 0.10 \cdot \text{Interview} + 0.10 \cdot \text{Consistency}$$
- **Component Formulas & Sources**:
  1. **DSA Component (0.25 weight)**:
     $$\text{DSA} = 0.70 \cdot \text{DSA\_Mastery} + 0.30 \cdot \left(\frac{\text{DSA\_Accepted}}{\text{DSA\_Attempted}} \times 100\right)$$
  2. **CS Fundamentals (0.20 weight)**:
     Weighted average of skill graph mastery across CSF areas: DBMS, Operating Systems, Computer Networks, and OOP (`app/services/skill_graph.py:CSF_AREAS`).
  3. **Coding Performance (0.20 weight)**:
     $$70\% \text{ Accepted Ratio} + 30\% \text{ Mean Solve Speed}$$
     $$\text{Speed Score} = \min\left(1.0, \frac{\text{Expected Time (ms)}}{\max(\text{Actual Time (ms)}, 1)}\right)$$
  4. **Aptitude Accuracy (0.15 weight)**:
     $$\text{Aptitude} = \frac{\text{Correct Aptitude Answers}}{\text{Total Aptitude Answered}} \times 100$$
  5. **Mock Interview (0.10 weight)**:
     Average overall score ($0–100$) across completed 5-dimension rubric mock interviews (`app/services/readiness_data.py:91-100`).
  6. **Consistency (0.10 weight)**:
     $$50\% \cdot \left(\frac{\min(\text{Streak}, 14)}{14} \times 100\right) + 50\% \cdot \left(\frac{\text{Active Days in last 14d}}{14} \times 100\right)$$
- **Step-by-Step Worked Numerical Example**:
  Suppose a student has:
  - DSA Mastery = $80.0$, DSA Accepted Ratio = $100\%$ ($4/4$) $\to \text{DSA} = 0.7(80) + 0.3(100) = 56 + 30 = \mathbf{86.0}$
  - CSF Mastery (DBMS: 70, OS: 60, CN: 65, OOP: 75) $\to \text{CSF} = \mathbf{67.5}$
  - Coding: 5 attempted, 4 accepted (80%), Mean solve speed = 0.75 $\to \text{Coding} = 70(0.80) + 30(0.75) = 56 + 22.5 = \mathbf{78.5}$
  - Aptitude: 18 correct out of 20 answered $\to \text{Aptitude} = \frac{18}{20} \times 100 = \mathbf{90.0}$
  - Mock Interview: 1 completed interview with score $\mathbf{74.0}$
  - Consistency: Streak = 7 days, Active days in last 14 = 7 days $\to \text{Consistency} = 50(7/14) + 50(7/14) = 25 + 25 = \mathbf{50.0}$
  
  $$\text{CRS} = (0.25 \times 86.0) + (0.20 \times 67.5) + (0.20 \times 78.5) + (0.15 \times 90.0) + (0.10 \times 74.0) + (0.10 \times 50.0)$$
  $$\text{CRS} = 21.50 + 13.50 + 15.70 + 13.50 + 7.40 + 5.00 = \mathbf{76.60\%}$$

### Level 3: Spoken Viva Defense & Follow-Up
> **How to speak in viva**:  
> *"The Company Readiness Score is defined by Equation 3.1. It is a completely auditable, weighted multi-criteria decision metric. It balances technical depth (DSA 25%, CSF 20%), practical execution (Coding 20%), cognitive ability (Aptitude 15%), verbal readiness (Interview 10%), and preparation habits (Consistency 10%). The weights can be overridden by specific company profiles, and if data is missing, the component scores 0.0 with an explicit note—it is never guessed."*

- **Examiner Follow-Up Question**: *"Does a readiness score of 85% mean the student has an 85% probability of getting placed?"*  
  **Your Answer**: *"No, sir. We explicitly clarify that the Company Readiness Score is a normalized measure of preparation competence against target company expectations. It is not a statistical placement probability, as hiring outcomes depend on external factors like vacancy counts and recruiter discretion."*

---

## Module 11: Student Analytics Dashboard

### Level 1: Beginner Metaphor
A car dashboard shows your speed, engine temperature, fuel level, and tire pressure. Our Analytics Dashboard gives students the same immediate visibility into their preparation: which topics are strong, which are failing, how fast they solve problems, and how their readiness compares across different target companies.

### Level 2: Technical Deep Dive
- **Implementation Location**:
  - Backend: `backend/app/routers/progress.py` (`get_my_analytics()`, lines 180–280)
  - Frontend: `frontend/src/app/(app)/analytics/page.tsx`, `frontend/src/components/charts.tsx`
- **Aggregated Metrics**:
  - `accuracy_over_time`: Daily array of `{date, answered, correct, accuracy}` over selectable windows (14d, 30d, 90d).
  - `topic_mastery`: Bar chart array of `{topic, mastery_score, target_mastery}`.
  - `difficulty_distribution`: Solved counts across `easy`, `medium`, and `hard`.
  - `time_per_question`: Histogram comparing student solve times against expected target benchmarks.
  - `company_readiness`: Horizontal bar comparison across all target companies the student selected.
  - `weakest_topics`: Ranked list of the top 5 weakest leaf topics, with direct "Study Now" action buttons.
- **Traceability Guarantee**: Every metric is calculated directly from `attempts`, `submissions`, and `mastery` tables in SQLite/Postgres. There are zero synthetic or randomized numbers.

### Level 3: Spoken Viva Defense & Follow-Up
> **How to speak in viva**:  
> *"The Analytics Dashboard visualizes the student's learning journey using Recharts. Students can toggle between 14-day, 30-day, and 90-day time horizons. Every chart includes an accessible data-table view, and the dashboard directly identifies the student's five largest weighted skill gaps with one-click navigation to remediate them in Study Mode."*

---

## Module 12: RAG Knowledge Base & AI Tutor

### Level 1: Beginner Metaphor
Think of an open-book exam. If you ask a student a question and take away their book, they might make up an answer (hallucinate). But if you place the exact official textbook open in front of them and tell them: *"Answer using only this page, and write down the page number where you found it"*, their answer will be accurate and verifiable. That is how RAG (Retrieval-Augmented Generation) works.

### Level 2: Technical Deep Dive
- **Implementation Location**:
  - Ingestion & Search: `backend/app/services/rag.py` (141 lines)
  - Tutor Modes: `backend/app/services/tutor.py` (351 lines)
  - Guardrails: `backend/app/services/guardrails.py` (198 lines)
  - Frontend: `frontend/src/app/(app)/tutor/page.tsx`
- **Vector Embedding & Ingestion**:
  - Text chunking: Paragraph-aware chunking with `CHUNK_CHARS = 900` and `OVERLAP_CHARS = 150` (`rag.py:41`).
  - Embedding Model: Google Gemini `gemini-embedding-001`, producing 768-dimensional dense vectors.
  - Indexing: Stored in `documents.embedding`. In PostgreSQL, indexed via `HNSW` (`m=16, ef_construction=64`).
- **Retrieval & Re-Ranking (`rag.py:search()`)**:
  - Computes query vector $q_v$ via `llm.embed(task="RETRIEVAL_QUERY")`.
  - Cosine distance lookup: $1 - \text{cosine\_distance}(q_v, d.embedding)$.
  - Metadata boost: $+0.05$ similarity boost if chunk `topic_id` matches query scope; $+0.05$ if `company_id` matches.
  - Floor threshold: Discards chunks with similarity $< 0.55$ (`MIN_SCORE_REAL`).
  - Returns top-k chunks with reference tokens (`S12`, `S15`).
- **The Six Bounded Tutoring Modes**:
  1. `explain`: Grounded conceptual explanation with key points and concrete code examples (`ExplainOut`).
  2. `hint`: Directional hint moving student one step closer without leaking correct options or full code (`HintOut`).
  3. `interviewer`: Asks one technical question on a target company focus area (`InterviewerOut`).
  4. `evaluate`: Grades student's written answer 0–10 against expected concepts and sources (`EvaluateOut`).
  5. `followup`: Probes edge cases and tradeoffs from the previous exchange (`FollowupOut`).
  6. `revision`: Generates practice items targeting previously incorrect submissions (`RevisionOut`).
- **Citation Guardrail (`guardrails.py:check_citations()`)**:
  - Validates that every citation tag (e.g. `[S14]`) in the LLM output matches an actually retrieved chunk. Hallucinated citations are stripped.
- **Workflow Diagram**: Defined in [`RAG_AI_Tutor_Flow.mmd`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/diagrams/RAG_AI_Tutor_Flow.mmd).

### Level 3: Spoken Viva Defense & Follow-Up
> **How to speak in viva**:  
> *"Our AI Tutor is built on Retrieval-Augmented Generation over 768-dimensional Gemini embeddings. Unlike ungrounded chatbots that hallucinate, our tutor searches a curated knowledge base using pgvector HNSW cosine distance. If similarity drops below 0.55, the model refuses to guess. Furthermore, our post-processing guardrail verifies every source citation, ensuring that students receive trustworthy, syllabus-grounded tutoring."*

- **Examiner Follow-Up Question**: *"How do you prevent the AI Tutor from giving away the answer when the student asks for a hint?"*  
  **Your Answer**: *"In `app/services/tutor.py:hint()`, we extract confidential answer keys into a forbidden fragments list. The LLM prompt explicitly commands directional hints only. If the LLM output contains any forbidden fragments or sets `reveals_answer=True`, the response is intercepted, regenerated with stricter constraints, and if it leaks again, replaced with a safe generic hint (`_generic_hint`). The answer is never leaked."*

---

## Module 13: AI Code Review

### Level 1: Beginner Metaphor
When you finish writing code in an interview, the interviewer doesn't just say "pass" or "fail". They say: *"Your code works, but what is its time complexity? Can you do it in $O(N)$ space instead of $O(N^2)$? What happens if the input array is empty?"* AI Code Review acts like that senior technical interviewer.

### Level 2: Technical Deep Dive
- **Implementation Location**:
  - Backend: `backend/app/services/code_review.py` (85 lines)
  - Frontend: `frontend/src/components/CodeReviewPanel.tsx`
- **Architectural Boundary**:
  - Enforced in code: AI Code Review **refuses to run** while a submission is queued or running, or if Judge0 encounters an internal error (`code_review.py:38-41`).
  - It runs **strictly after** Judge0 returns an authoritative verdict.
  - The Pydantic output contract `CodeReviewOut` has **no verdict or score field**, making it impossible for the model to overturn the judge.
- **Outputs Provided**:
  - `summary` (Text)
  - `time_complexity` (e.g. $O(N \log N)$)
  - `space_complexity` (e.g. $O(1)$)
  - `quality` (Style, variable naming, idiomatic constructs)
  - `edge_cases` (Empty arrays, single elements, integer overflow)
  - `potential_defects` (Missed bounds, unhandled nulls)
  - `alternative_approach` (e.g. hash map vs two pointers)
- **Contradiction Stripping (`guardrails.py:strip_verdict_contradictions()`)**:
  - If Judge0 marked the code "Accepted", but the LLM hallucinates *"This code fails on negative inputs"*, regex filters detect and strip the contradictory sentence before writing to `verdict.details["ai_review"]`.

### Level 3: Spoken Viva Defense & Follow-Up
> **How to speak in viva**:  
> *"AI Code Review exemplifies our strict boundary between deterministic evaluation and generative AI. The AI model is never asked 'Is this code correct?'—Judge0 has already answered that with mathematical certainty. The AI is asked 'Why is this code $O(N)$ and how could it be written more idiomatically?' Sentences contradicting the authoritative verdict are automatically stripped."*

---

## Module 14: Resume & Job Description Gap Analysis

### Level 1: Beginner Metaphor
Imagine an automated placement officer comparing your resume against a company's job description. The officer highlights the skills you have in green (e.g., Python, SQL, Git), highlights the missing skills you need in red (e.g., Docker, Redis), and hands you a personalized study checklist to close the gap before the interview.

### Level 2: Technical Deep Dive
- **Implementation Location**:
  - Backend: `backend/app/services/career.py` (234 lines), `backend/app/routers/career.py`
  - Frontend: `frontend/src/app/(app)/career/page.tsx`
- **File Upload Security (`validate_upload`)**:
  - Validates extension (`.pdf`, `.txt`), declared MIME type, and file size (max 5MB).
  - Inspects file magic bytes: PDF files must start with `b"%PDF-"`.
  - Disallows encrypted PDFs (`pypdf.PdfReader.is_encrypted`).
- **Asynchronous Parsing (`parse_resume`, `parse_jd`)**:
  - Extracts raw text using `pypdf`.
  - LLM extracts structured entities into Pydantic models: `ResumeParsed` (skills, projects, experience, education) and `JDParsed` (required skills, technologies, responsibilities).
- **Deterministic Skill Gap Matching (`career.py:compare()`)**:
  - Canonical alias normalization (`ALIASES` dict):
    `psql` $\to$ `postgresql`, `cpp` $\to$ `c++`, `oops` $\to$ `oop`, `k8s` $\to$ `kubernetes`.
  - Weighted Job Readiness Formula:
    $$\text{Job Readiness} = 100 \times \frac{\sum \text{Matched Weights}}{\sum \text{Total Requirement Weights}}$$
    *(Required skills carry weight 2; technologies carry weight 1).*
  - Actionable Remediation: Missing skills mapped directly to platform topic slugs via `SKILL_TOPIC` (e.g. missing `SQL` $\to$ link to `/study/normalization`).

### Level 3: Spoken Viva Defense & Follow-Up
> **How to speak in viva**:  
> *"Our resume matching is deterministic. While the LLM is used to extract unstructured text into structured skill lists, the comparison algorithm and job readiness percentage use normalized string matching with canonical aliases. Required skills weigh double, and missing requirements link directly to platform study modules."*

---

## Module 15: Interactive Mock Interview System

### Level 1: Beginner Metaphor
Imagine a mock technical interview conducted over chat with a corporate interviewer. The interviewer asks you an opening problem tailored to Amazon. You type your approach. The interviewer evaluates your response, challenges you with a follow-up constraint ("What if memory is limited to 10MB?"), and at the end of 4 turns, grades you across 5 standard corporate dimensions.

### Level 2: Technical Deep Dive
- **Implementation Location**:
  - Backend: `backend/app/services/interview.py` (261 lines), `backend/app/routers/interview.py`
  - Frontend: `frontend/src/app/(app)/interview/page.tsx` (432 lines)
- **Multi-Turn Interaction Loop**:
  - `POST /api/v1/interviews`: Initializes session, searches RAG for company questions, generates opening question via `OpeningQuestionOut`.
  - `POST /api/v1/interviews/{id}/turn`: Appends student written answer; LLM generates 1-sentence evaluation snippet and adaptive follow-up (`TurnFollowUpOut`). Turn 4 triggers `suggest_finish = True`.
  - `POST /api/v1/interviews/{id}/finish`: Evaluates full transcript across the 5-dimension rubric.
- **The 5-Dimension Rubric (Table 3.3, Scale 1–10)**:
  1. **Technical Knowledge**: Correctness and depth of domain content.
  2. **Problem Solving**: Approach, decomposition, and handling of constraints.
  3. **Communication**: Clarity, structure, and precision of written explanation.
  4. **Confidence**: Decisiveness and handling of challenges or corrections.
  5. **Concept Accuracy**: Absence of misconceptions and correct terminology.
- **Readiness Score Integration**:
  - Scaled overall score: $\text{Overall} = \left(\frac{\sum \text{Scores}}{5}\right) \times 10$ ($0–100$ scale).
  - Stored in `interviews.scores["overall_score"]`.
  - Read by `readiness_data.py:91-100` to power the 10% Interview component in Equation 3.1.
- **Ethical AI Disclosure**:
  - Stored in report and rendered in UI:
    `"Communication and Confidence dimensions are inferred from written responses, not actual voice or behavioural measurements."`

### Level 3: Spoken Viva Defense & Follow-Up
> **How to speak in viva**:  
> *"Our Mock Interview subsystem provides multi-turn conversational preparation evaluated against a 5-dimension rubric on a 1-to-10 scale. The overall score directly feeds the Interview component of Equation 3.1. In accordance with ethical AI guidelines, we prominently disclose that Communication and Confidence are inferred from written structure, precision, and decisiveness, without claiming voice or facial acoustics."*

- **Examiner Follow-Up Question**: *"Why limit the session to 4 turns?"*  
  **Your Answer**: *"Four substantive turns provide sufficient transcript depth for rubric evaluation while keeping latency, token costs, and student cognitive fatigue within practical parameters."*

---

## Module 16: Multi-Agent Orchestrator & Adaptive Roadmaps

### Level 1: Beginner Metaphor
Imagine a company placement office staffed by 7 specialists. When you walk in, the **Receptionist (Triage Agent)** asks what you need. If you want a plan, she directs you to the **Placement Advisor (Placement Agent)**, who creates a 20-day schedule. If you later fail a diagnostic test on Graphs, the **Tutor (Recommendation Agent)** intercepts your schedule, extends Graphs practice for two extra days, and postpones advanced Dynamic Programming.

### Level 2: Technical Deep Dive
- **Implementation Location**:
  - Backend: `backend/app/services/agents/orchestrator.py` (185 lines), `backend/app/services/roadmap.py` (219 lines)
  - Frontend: `frontend/src/app/(app)/roadmap/page.tsx` (337 lines)
- **The Seven Bounded Agents**:
  1. **Triage Agent (`triage_student_intent`)**: Classifies free-form requests into 6 intents with confidence scores (`TriageDecisionOut`).
  2. **Tutor Agent**: Executes grounded Socratic tutoring via RAG.
  3. **Assessment Agent**: Selects diagnostic question sequences based on target difficulty.
  4. **Interview Agent**: Conducts multi-turn mock interviews and evaluates rubric scores.
  5. **Placement Agent (`placement_agent_build_roadmap`)**: Synthesizes company-specific schedules based on deadline and weak areas (`GeneratedRoadmapPlanOut`).
  6. **Analytics Agent**: Aggregates attempt logs into readiness metrics and trendlines.
  7. **Recommendation Agent (`recommendation_agent_revise_roadmap`)**: Dynamically adapts active roadmaps when assessment failures occur (`RoadmapRevisionOut`).
- **Dynamic Plan Revision Trigger**:
  - When a student scores $<50\%$ on a topic assessment, `revise_roadmap()` is invoked.
  - The Recommendation Agent dynamically modifies the schedule: extends revision on the struggled topic, inserts remedial practice, and postpones advanced topics.
  - Increments `roadmap.version`, records revision history, and logs actionable entries in the `recommendations` table.
- **Workflow Diagram**: Defined in [`Agent_Orchestration_Flow.mmd`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/diagrams/Agent_Orchestration_Flow.mmd).

### Level 3: Spoken Viva Defense & Follow-Up
> **How to speak in viva**:  
> *"Our multi-agent system uses a central Triage Agent to coordinate six specialized agents with strictly bounded responsibilities. Unlike static study plans, our roadmap engine is dynamically adaptive: when a student fails a topic assessment, the Recommendation Agent revises the active plan, scheduling remedial concepts and postponing advanced topics to maintain realistic preparation timelines."*

- **Examiner Follow-Up Question**: *"Do your agents communicate autonomously with each other or through a coordinator?"*  
  **Your Answer**: *"They coordinate through a central orchestrator. Autonomous agent-to-agent chatter frequently leads to infinite loops, high token costs, and unpredictable hallucinations. Our orchestrator enforces structured Pydantic handoffs at every stage."*

---

## Module 17: Admin & AI Guardrails

### Level 1: Beginner Metaphor
A water treatment plant has filters and testing valves at every stage to ensure that what comes out of your tap is 100% safe to drink. Our Admin & AI Guardrails inspect incoming student prompts to block malicious injections, verify that AI-generated questions meet syllabus quality standards before entering the database, and monitor API costs.

### Level 2: Technical Deep Dive
- **Implementation Location**:
  - Backend: `backend/app/services/guardrails.py`, `backend/app/services/generation.py`, `backend/app/routers/ai.py`
  - Frontend: `frontend/src/app/(app)/admin/ai/page.tsx`, `frontend/src/app/(app)/admin/review/page.tsx`
- **Input Sanitization (`clean_input`)**:
  - Checks for prompt injection patterns (`ignore previous instructions`, `system prompt`, `jailbreak`).
  - Strips null bytes and normalizes excessive whitespace.
  - Wraps user input in `<student_input>` XML delimiters to prevent context leakage.
- **AI Question Generation & Review Queue**:
  - Admins trigger AI question generation with strict Pydantic schemas.
  - Generated questions are created with `status = "draft"` and `source = "ai"`.
  - Enter the Admin Review Queue (`/admin/review`). Questions **never enter the active student question bank** until an admin or content manager reviews, re-validates on Judge0, and approves them.
- **AI Observability & Cost Tracking**:
  - Every single LLM and embedding call commits an `AITrace` row (`prompt_tokens`, `completion_tokens`, `latency_ms`, `cost_usd`, `model`, `success`).
  - `/api/v1/ai/stats` aggregates total costs, latencies, error rates, and cache hit rates.

### Level 3: Spoken Viva Defense & Follow-Up
> **How to speak in viva**:  
> *"Our AI subsystem enforces end-to-end guardrails. On input, we clean text and encapsulate student queries in boundary delimiters to prevent prompt injection. For content curation, AI-generated questions are placed in an isolated draft review queue where they must pass human approval and Judge0 validation before publication. Every call is audited for latency, tokens, and cost in our `ai_traces` table."*

---

## Module 18: Notifications & Engagement Layer

### Level 1: Beginner Metaphor
A gym coach sends you a reminder when you haven't visited in 4 days, congratulates you when you hit a 7-day streak, and awards you milestone badges. Our notification and engagement system motivates students to maintain daily preparation consistency without introducing unhealthy competition.

### Level 2: Technical Deep Dive
- **Implementation Location**:
  - Backend: `backend/app/services/notifications.py` (291 lines), `backend/app/routers/notifications.py`
  - Models: `app/models/domain.py` (`Notification`, `UserEngagement`)
- **Six Notification Categories**:
  `daily_study`, `scheduled_test`, `weak_topic`, `streak`, `weekly_summary`, `company_deadline`.
- **Smart Notification Generation (`generate_smart_notifications()`)**:
  - Scans `mastery` table: if a student has a weak topic (mastery $<60\%$) with `last_attempt > 4 days ago`, generates an automated revision reminder.
  - Scans `profiles` table to trigger streak celebration notifications.
- **Engagement Mechanics**:
  - XP awarded for practice, test completions, and milestone events.
  - Badges: `first_step` (first study session), `code_runner` (first Judge0 submission), `streak_master` (7-day streak), `interview_ready` (first mock interview).
  - **Opt-In Leaderboard**: Disabled by default (`leaderboard_opt_in = False`) per academic guidelines to protect student psychological well-being and privacy.

### Level 3: Spoken Viva Defense & Follow-Up
> **How to speak in viva**:  
> *"Our notification system is rule-driven, scanning student attempt timestamps to generate smart reminders for weak topics unpracticed for more than four days. Our engagement layer includes XP and badges, but crucially, the leaderboard is strictly opt-in by default, respecting institutional ethical guidelines regarding student privacy."*

---

## Module 19: Student Data Privacy & GDPR/DPDP Portability

### Level 1: Beginner Metaphor
Under global data privacy laws, you own your data. When you close a bank account, you have the right to get a complete printed statement of all your transactions (Data Portability), or request that the bank shred all your personal files (Right to Erasure). PrepPath gives students these exact digital rights.

### Level 2: Technical Deep Dive
- **Implementation Location**:
  - Backend: `backend/app/routers/users.py` (lines 62–245)
  - Frontend: `frontend/src/app/(app)/profile/page.tsx` (lines 22–52, 151–167)
- **Data Portability (`GET /api/v1/users/me/export`)**:
  - Compliant with **GDPR Article 20** and **India Digital Personal Data Protection (DPDP) Act**.
  - Aggregates all user-owned data across 8 tables: user profile, mastery records, test attempts, code submissions with Judge0 verdicts, readiness history snapshots, parsed resumes, mock interview transcripts with rubric scores, and active preparation roadmaps.
  - Streams a structured, indented JSON export file to the student's browser.
- **Right to Erasure (`DELETE /api/v1/users/me`)**:
  - Permanently purges user record from the database.
  - Foreign key cascading (`ondelete="CASCADE"`) automatically purges child rows in `profiles`, `attempts`, `submissions`, `mastery`, `interviews`, `roadmaps`, `resumes`, and `notifications`.
  - Physical file cleanup: Unlinks and deletes stored PDF/TXT resume files from disk storage.

### Level 3: Spoken Viva Defense & Follow-Up
> **How to speak in viva**:  
> *"We built first-class data privacy compliance into PrepPath aligned with GDPR and the Indian DPDP Act. A student can export their complete learning history as structured JSON with one click, or trigger permanent account deletion, which cascades through all database records and physically deletes uploaded resume files from the server disk."*

---

## Module 20: DevOps, Infrastructure & Containerization

### Level 1: Beginner Metaphor
Shipping code without containers is like sending furniture as raw wood and screws—it might not fit together on someone else's floor. Docker packages the entire furnished room with all its tools, plumbing, and electricity inside a standardized container that works identically on any operating system.

### Level 2: Technical Deep Dive
- **Implementation Location**:
  - `major1/docker-compose.yml` (115 lines)
  - `major1/backend/Dockerfile` (Multi-stage Python 3.12-slim)
  - `major1/frontend/Dockerfile` (Multi-stage Node.js 22-alpine)
- **Container Topology**:
  - `preppath_postgres`: `pgvector/pgvector:pg16` with healthcheck (`pg_isready`).
  - `preppath_redis`: `redis:7-alpine` with healthcheck (`redis-cli ping`).
  - `preppath_backend`: FastAPI app running with non-root user and curl healthcheck.
  - `preppath_worker`: Celery worker instance processing background queues.
  - `preppath_frontend`: Next.js 15 standalone server.
  - `preppath_judge0`: Sandboxed execution container profile (`judge0-sandbox`).
- **Production Hardening**:
  - Multi-stage Docker builds reduce frontend image size from 1.2GB to under 120MB.
  - Backend containers run as non-root unprivileged users for defense-in-depth.
  - Docker Compose service dependencies use `condition: service_healthy` to prevent race conditions during startup.

### Level 3: Spoken Viva Defense & Follow-Up
> **How to speak in viva**:  
> *"Our platform is fully containerized using multi-stage Dockerfiles and Docker Compose. We orchestrate PostgreSQL with pgvector, Redis, FastAPI, Celery, and Next.js standalone output. Services use healthchecks to ensure strict startup sequencing, and all application processes run under non-root unprivileged users for container security."*
