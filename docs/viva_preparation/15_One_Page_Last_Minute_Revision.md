# Document 15: Last-Minute Viva Revision Sheet (The 10-Minute Cheat Sheet)

> **When to Read**: Outside the Examination Hall 10–15 Minutes Before Entering  
> **Purpose**: Instant Memory Refresh of Core Formulas, Architectural Facts, Ports, and File Paths  

---

## 1. Project Identity & Elevator Pitch
- **Title**: **PrepPath** — AI-Powered Adaptive Placement Preparation Platform
- **Authors**: Palak Mathur, Ansh Upadhyay, Tanmay Gupta | **Supervisor**: Respected Deepti Singh (JIIT Noida)
- **One-Sentence Definition**: An integrated, company-targeted engineering placement preparation platform that combines sandboxed code execution, deterministic skill-mastery tracking, and retrieval-augmented generative AI into a unified adaptive preparation workflow.
- **The Core Problem**: Placement preparation is fragmented across LeetCode (DSA only), GeeksforGeeks (static articles), and IndiaBIX (aptitude), offering no company-specific weighting, no unified readiness metric, and no adaptive feedback.

---

## 2. Technology Stack & Key Infrastructure Facts
- **Frontend**: Next.js 15.1 (App Router), React 19, TypeScript 5.7, Tailwind CSS v4, Monaco Editor (`@monaco-editor/react`), Recharts.
- **Backend**: FastAPI 0.115, Python 3.12, Pydantic v2, SQLAlchemy 2.0 Async, Alembic.
- **Databases**: PostgreSQL 16 with `pgvector` (production with HNSW index); SQLite (`dev.db` via `aiosqlite`) for zero-setup local dev/testing.
- **Asynchronous Task Queue**: Celery with Redis 7 broker (in-process `asyncio.create_task` fallback when Redis is absent).
- **Code Execution**: Judge0 CE sandboxed container running inside Linux cgroups.
- **Generative AI & Embeddings**: Google Gemini (`gemini-flash-lite-latest` for fast tasks, `gemini-flash-latest` for evaluations/interviews, `gemini-embedding-001` producing 768-d vectors). Deterministic `MockLLMClient` fallback.
- **Security**: Argon2id password hashing, 15m in-memory access token, httpOnly rotating refresh cookie, session family reuse revocation, scoped RBAC (`me`, `content:write`, `admin:panel`).

---

## 3. The Two Core Mathematical Formulas (Know Cold!)

### Formula 1: Company Readiness Score (Equation 3.1)
$$\text{CRS} = 0.25(\text{DSA}) + 0.20(\text{CSF}) + 0.20(\text{Coding}) + 0.15(\text{Aptitude}) + 0.10(\text{Interview}) + 0.10(\text{Consistency})$$
- $\text{DSA} = 0.70 \cdot \text{DSA\_Mastery} + 0.30 \cdot (\text{Accepted} / \text{Attempted} \cdot 100)$
- $\text{CSF} = \text{Weighted Mastery across DBMS, OS, Computer Networks, and OOP}$
- $\text{Coding} = 70 \cdot (\text{Accepted} / \text{Attempted}) + 30 \cdot \text{mean}(\min(1.0, \text{Expected Time} / \text{Actual Time}))$
- $\text{Aptitude} = (\text{Correct} / \text{Answered}) \cdot 100$
- $\text{Interview} = \text{Mean of completed 5-dimension rubric mock interview scores } (0\text{--}100)$
- $\text{Consistency} = 50 \cdot (\min(\text{Streak}, 14) / 14) + 50 \cdot (\text{Active Days in Last 14} / 14)$

### Formula 2: Bayesian Elo Skill Mastery Update (`app/services/mastery.py`)
$$\Delta = \text{clamp}\left(\text{lr} \cdot w \cdot (\text{target} - \text{mastery}), -15.0, +15.0\right)$$
- $\text{Target} = 100.0$ if correct, $0.0$ if wrong.
- $\text{lr} = \max(0.15, 1 / (n + 2))$ *(Decays as attempt count $n$ grows).*
- $w_{\text{correct}} = d \cdot \text{clamp}(1.2 - 0.2 \cdot (\text{time} / \text{expected}), 0.8, 1.1) \cdot (0.85 + 0.15 \cdot \text{conf})$
- $w_{\text{wrong}} = (2.0 - d) \cdot (1.0 + 0.3 \cdot \text{conf})$ *(Missing easy hurts more; confident wrong answer triggers 30% misconception penalty!)*
- Difficulty ($d$): Easy = 0.7, Medium = 1.0, Hard = 1.3.

---

## 4. Key Subsystems & Workflows at a Glance

### 1. Monaco & Judge0 Execution Pipeline
- Client writes code in Monaco $\to$ `POST /api/v1/submissions` $\to$ Returns HTTP 202 Accepted.
- Background worker dispatches batch to Judge0 container: `POST /submissions/batch`.
- Code executed in Linux cgroups (2.0s time limit, 128MB RAM).
- Client polls `GET /submissions/{id}` $\to$ Returns status code (3: Accepted, 4: WA, 5: TLE, 6: CE, 7: RE).
- AI Code Review runs strictly **after** Judge0 returns an authoritative verdict.

### 2. RAG AI Tutor (6 Bounded Modes)
- Paragraph-aware chunking (900 chars, 150 overlap) $\to$ Gemini 768-d embedding $\to$ pgvector HNSW index.
- Vector search with metadata boost (+0.05 topic, +0.05 company) and floor ($\ge 0.55$). If below 0.55 $\to$ Refuses to guess!
- 6 Modes: Explain, Hint (anti-leak regex), Interviewer, Evaluate, Follow-up, Revision.
- Citations verified: all cited `[S#]` must exist in retrieved chunks.

### 3. The Seven Bounded Agents (`orchestrator.py`)
1. **Triage Agent**: Classifies student intent into 6 paths.
2. **Tutor Agent**: Delivers grounded Socratic explanations.
3. **Assessment Agent**: Selects diagnostic questions by target difficulty ($<35$ easy, $<70$ medium, $\ge 70$ hard).
4. **Interview Agent**: Conducts multi-turn mock interviews and evaluates 5-dimension rubric.
5. **Placement Agent**: Synthesizes 20-day company preparation roadmap.
6. **Analytics Agent**: Aggregates attempt history into Equation 3.1 readiness.
7. **Recommendation Agent**: Dynamically adapts active roadmap when assessment score $< 50\%$.

### 4. Mock Interview System (5 Rubric Dimensions)
- 4-turn conversational exchange $\to$ Graded on scale 1–10:
  1. Technical Knowledge, 2. Problem Solving, 3. Communication, 4. Confidence, 5. Concept Accuracy.
- Overall score: $\text{mean} \times 10 \to [0, 100]$, feeding directly into Equation 3.1.
- Ethical Disclosure: Communication and Confidence are inferred from written text structure, not voice/video.

---

## 5. Five Strongest Spoken Answers (Deliver with Confidence!)

1. **"What is deterministic and what is AI?"**  
   *"Code judging (Judge0), test grading, skill mastery updates, and the Company Readiness Score (Equation 3.1) are 100% deterministic, auditable Python math. Generative AI is strictly confined to pedagogical explanations, directional hints, and conversational interviewing under Pydantic schema validation."*
2. **"Why use Next.js instead of plain React?"**  
   *"Plain React SPAs send an empty HTML shell that produces blank loading screens. Next.js App Router provides server-side rendering for instant page loads, nested layouts, and built-in route optimization."*
3. **"Why Judge0 instead of Python exec()?"**  
   *"Using `exec()` allows remote code execution (RCE)—a student could delete the server filesystem or steal database passwords. Judge0 executes code inside an isolated, unprivileged Linux container sandbox with strict CPU and RAM limits."*
4. **"What makes your system adaptive?"**  
   *"Micro-adaptivity in Study Mode selects question difficulty from skill mastery and updates scores using Bayesian Elo decay. Macro-adaptivity in our Roadmap Engine dynamically adapts the 20-day schedule when a student scores below 50% on an assessment."*
5. **"What is the biggest limitation?"**  
   *"Mock interview communication and confidence are inferred from written response structure and precision rather than live voice acoustics or facial video expressions, which we explicitly disclose in our UI."*

---

## 6. Key Ports, Files & Verification Numbers
- **Ports**: Frontend: `3000` | Backend: `8000` | PostgreSQL: `5432` | Redis: `6379` | Judge0: `2358`
- **Key Files**:
  - Mastery: `backend/app/services/mastery.py`
  - Readiness: `backend/app/services/readiness.py` & `readiness_data.py`
  - RAG: `backend/app/services/rag.py` & `tutor.py`
  - Judge0: `backend/app/services/judge.py`
  - Orchestrator: `backend/app/services/agents/orchestrator.py`
  - Privacy: `backend/app/routers/users.py:62-245`
- **Verified Facts**: 90/90 backend tests passing (25.13s) | 0 frontend TypeScript compile errors | 85.7% RAG Faithfulness | 100% Out-of-Corpus Refusal Correctness.
