# Document 13: Comprehensive Viva Questions and Answers Bank (125 Q&As)

> **Structure**: 9 Dedicated Sections (A through I) · 125 In-Depth Questions and Answers  
> **Standard**: Direct Answer $\to$ Simple Explanation $\to$ PrepPath Implementation Code Connection $\to$ Follow-Up Question  
> **Source Repository Location**: `major1/`  

---

## Section A: Project Fundamentals (15 Questions)

### Q01: What is PrepPath in one simple sentence?
- **Direct Answer**: PrepPath is an integrated, company-targeted engineering placement preparation platform that combines sandboxed code execution, deterministic skill-mastery tracking, and retrieval-augmented generative AI into a unified adaptive preparation workflow.
- **Simple Explanation**: Instead of visiting LeetCode for coding, GeeksforGeeks for theory, and IndiaBIX for aptitude, a student uses PrepPath for their complete preparation journey tailored to their target company.
- **Code Connection**: The root entrypoint is configured in `major1/backend/app/main.py` and `major1/frontend/src/app/`.
- **Follow-Up Question**: *"What problem does it solve for college students?"* $\to$ *"It eliminates context switching across fragmented websites and provides an auditable Company Readiness Score based on real practice evidence."*

### Q02: Why did you build this project when LeetCode already exists?
- **Direct Answer**: LeetCode focuses almost exclusively on competitive programming and DSA; it does not cover Computer Science Fundamentals (DBMS, OS, Networks, OOP), Quantitative Aptitude, Socratic AI tutoring, or mock interviews.
- **Simple Explanation**: Campus recruitment tests multiple subjects, not just algorithms. LeetCode prepares you for only one slice of the placement test.
- **Code Connection**: Our taxonomy (`app/models/content.py:Topic`) explicitly models 6 core domains: DSA, DBMS, OS, CN, OOP, and Aptitude.
- **Follow-Up**: *"Does PrepPath replace LeetCode?"* $\to$ *"It complements deep competitive programming by providing an integrated preparation lifecycle tailored to specific company hiring patterns."*

### Q03: What are the three primary roles supported by your platform?
- **Direct Answer**: The three roles are `student`, `content_manager`, and `admin`.
- **Simple Explanation**: Students practice and take assessments; content managers curate syllabus questions; administrators monitor AI costs, audit logs, and approve AI-generated content.
- **Code Connection**: Defined in `app/models/identity.py:Role` and seeded in `app/seed.py:seed_roles()`.
- **Follow-Up**: *"How is access restricted?"* $\to$ *"Through scoped OAuth2 tokens enforced by FastAPI dependency `require_scopes()` in `app/core/deps.py`."*

### Q04: How does a student begin using PrepPath?
- **Direct Answer**: A student registers, configures their academic details and target companies in their Profile, receives an initial personalized roadmap, and begins diagnostic practice in Study Mode.
- **Simple Explanation**: The student signs up, tells the platform where they want to work (e.g. Amazon), and the system generates a tailored preparation schedule.
- **Code Connection**: Flow starts at `POST /api/v1/auth/register` $\to$ `PUT /api/v1/users/me/profile` $\to$ `POST /api/v1/roadmaps/generate`.

### Q05: Where did you get the company intelligence data for Amazon, TCS, and Microsoft?
- **Direct Answer**: Data was curated from publicly available campus recruitment debriefs, verified placement archives, and observed historical hiring distributions at JIIT.
- **Simple Explanation**: We analyzed placement patterns from recent recruitment seasons to model what percentage of questions each company asks in DSA vs Aptitude vs Core CS.
- **Code Connection**: Seeded in `backend/app/seed_content.py:seed_companies()`.
- **Follow-Up**: *"Do you claim this is an official recruiter syllabus?"* $\to$ *"No. Every company response injects a mandatory disclaimer: 'Observed historical preparation patterns — not official recruiter specifications'."*

### Q06: What is the core difference between your Study Mode and Test Mode?
- **Direct Answer**: Study Mode is a low-stakes, untimed 8-step learning loop with Socratic RAG explanations and worked examples; Test Mode is a high-stakes, timed assessment with server-enforced deadlines, negative marking, and no hints.
- **Simple Explanation**: Study Mode is for learning; Test Mode is for exam simulation.
- **Code Connection**: Implemented separately in `app/routers/study.py` vs `app/routers/tests.py`.

### Q07: Does PrepPath guarantee campus placement?
- **Direct Answer**: No, and we explicitly disclaim any placement guarantee.
- **Simple Explanation**: A platform can measure and improve a student's preparation competence, but final hiring depends on vacancies, company hiring freezes, and subjective panel interviews.
- **Code Connection**: Disclaimed in documentation and UI report headers (`src/components/company.tsx`).

### Q08: How do you define "adaptive learning" in this project?
- **Direct Answer**: Adaptivity operates on two levels: micro-adaptivity in Study Mode (dynamic question difficulty based on current skill mastery) and macro-adaptivity in Roadmaps (dynamic schedule revision when assessment scores drop below 50%).
- **Simple Explanation**: The system adjusts question difficulty to match your skill level, and rewrites your study calendar when you struggle with a topic.
- **Code Connection**: `app/services/mastery.py:target_difficulty()` (micro) and `app/services/roadmap.py:revise_roadmap()` (macro).

### Q09: What is the primary academic contribution of this work?
- **Direct Answer**: The formalization of a strict boundary architecture: keeping code execution, grading, skill mastery updates, and readiness scores 100% deterministic, while confining generative AI to bounded pedagogical tutoring and conversational coaching.
- **Simple Explanation**: We proved that you should never let an AI grade code or invent scores; AI should only teach, while math and sandboxes do the grading.
- **Code Connection**: Separation between `app/services/judge.py` / `mastery.py` (deterministic) and `app/services/tutor.py` (generative).

### Q10: How does the platform store user passwords?
- **Direct Answer**: Using the Argon2id hashing algorithm via the `pwdlib` library.
- **Simple Explanation**: We never store plain passwords. Argon2id converts the password into an irreversible, memory-hard cryptographic hash.
- **Code Connection**: `backend/app/core/security.py:hash_password()`.
- **Follow-Up**: *"Why Argon2id over bcrypt?"* $\to$ *"Argon2id is the winner of the Password Hashing Competition, specifically designed to resist hardware brute-forcing via GPUs and ASICs."*

### Q11: What programming languages can students submit in coding questions?
- **Direct Answer**: Python 3.13, C++ (GCC 14), Java 13, JavaScript (Node 22), and SQL (SQLite 3).
- **Simple Explanation**: The 5 standard languages tested in campus placement online assessments.
- **Code Connection**: Defined in `app/services/judge.py:LANGUAGES` mapping language keys to Judge0 language IDs.

### Q12: How are student coding solutions evaluated?
- **Direct Answer**: Submissions are dispatched asynchronously over HTTP to an isolated Judge0 CE container sandbox that compiles and executes the code against multi-test batches under CPU and RAM limits.
- **Simple Explanation**: Code is sent to a secure execution box that runs it against hidden tests and tells us if it passed or timed out.
- **Code Connection**: `app/services/judge.py:execute_batch()` and `app/services/judging.py`.

### Q13: What happens when a student asks the AI Tutor for a hint?
- **Direct Answer**: The system retrieves RAG context, extracts the question's answer into a forbidden fragments list, and prompts the LLM to give a directional hint without leaking the answer. If the hint leaks the answer, it is blocked and replaced with a safe generic hint.
- **Simple Explanation**: The AI points the student in the right direction without spoiling the solution.
- **Code Connection**: `backend/app/services/tutor.py:hint()` and `app/services/guardrails.py:leaks()`.

### Q14: How does PrepPath track student daily consistency?
- **Direct Answer**: By maintaining a `study_streak` counter and `last_active_on` date in the `profiles` table, verified against attempt timestamps in the `submissions` table over a sliding 14-day window.
- **Simple Explanation**: It tracks how many consecutive days you have practiced and how many active days you logged in the last two weeks.
- **Code Connection**: `app/services/readiness_data.py:85-90` and `app/models/identity.py:Profile`.

### Q15: Who supervised this project and what was their role?
- **Direct Answer**: Respected Deepti Singh, Department of CSE & IT, Jaypee Institute of Information Technology (JIIT), Noida.
- **Simple Explanation**: She provided academic mentorship, guided architectural milestones, and reviewed feature traceability against university major project requirements.

---

## Section B: Frontend and Backend Architecture (15 Questions)

### Q16: Why did you choose Next.js 15 instead of a plain React Single Page Application?
- **Direct Answer**: Next.js App Router provides server-side rendering (SSR) for fast initial loads, nested route layouts (`src/app/(app)/`), built-in bundle optimization, and server-side redirects, avoiding blank loading screens common in client-only SPAs.
- **Simple Explanation**: Plain React sends an empty HTML page that stays white until JavaScript loads. Next.js pre-renders HTML on the server so the dashboard appears instantly.
- **Code Connection**: `frontend/src/app/(app)/layout.tsx` and `frontend/package.json`.

### Q17: How is the access token stored and managed on the frontend?
- **Direct Answer**: Stored strictly in memory in a module-level variable in `src/lib/api.ts` (`let accessToken: string | null = null;`). It is never saved to `localStorage` or `sessionStorage`.
- **Simple Explanation**: It lives in RAM while the browser tab is open. If an attacker injects malicious JavaScript, there is no token in storage for them to steal.
- **Code Connection**: `frontend/src/lib/api.ts:4-8`.
- **Follow-Up**: *"How does the session survive page reloads?"* $\to$ *"On reload, the in-memory variable is null, triggering `refreshSession()`, which uses the httpOnly cookie to seamlessly fetch a new access token."*

### Q18: What is the role of FastAPI in your backend?
- **Direct Answer**: FastAPI serves as the asynchronous REST API gateway, handling HTTP routing, CORS headers, Pydantic request/response validation, dependency injection, and auto-generating OpenAPI documentation.
- **Simple Explanation**: It is the Python web server that receives frontend requests, verifies permissions, calls our services, and sends back JSON.
- **Code Connection**: `backend/app/main.py:29-50`.

### Q19: What is ASGI and why is it important for PrepPath?
- **Direct Answer**: Asynchronous Server Gateway Interface (ASGI) is the modern Python standard for asynchronous web servers (like Uvicorn). It allows handling thousands of concurrent non-blocking I/O connections on an `asyncio` event loop.
- **Simple Explanation**: Older servers (WSGI) block a whole thread while waiting for a database or Judge0. ASGI pauses the task and handles other requests while waiting, making it vastly faster.
- **Code Connection**: Backend runs via Uvicorn ASGI server in `Dockerfile` and `start.bat`.

### Q20: What is Dependency Injection in FastAPI and how do you use it?
- **Direct Answer**: Dependency Injection is an architectural pattern where required objects are declared as function parameters using `Depends()`. FastAPI resolves, creates, and disposes of them automatically per request.
- **Simple Explanation**: Instead of manually opening a database connection inside every function, you declare `db: AsyncSession = Depends(get_db)`, and FastAPI gives you a clean session and closes it when done.
- **Code Connection**: `app/core/db.py:get_db()` and `app/core/deps.py:require_scopes()`.

### Q21: How do you handle Cross-Origin Resource Sharing (CORS)?
- **Direct Answer**: Using FastAPI's `CORSMiddleware`, configured to allow requests from `http://localhost:3000` with `allow_credentials=True` and allowed methods `GET, POST, PUT, PATCH, DELETE`.
- **Simple Explanation**: Web browsers block frontend apps from calling backend APIs on different ports unless the backend explicitly gives permission via CORS headers.
- **Code Connection**: `backend/app/main.py:37-43` and `app/core/config.py:cors_origins`.

### Q22: What happens when an API request receives an HTTP 401 Unauthorized?
- **Direct Answer**: In `frontend/src/lib/api.ts`, our `api()` wrapper intercepts 401 responses, initiates `refreshSession()`, acquires a new access token via the httpOnly cookie, and transparently replays the original request.
- **Simple Explanation**: If your token expires while you are using the app, the frontend quietly refreshes your session in the background without interrupting your work.
- **Code Connection**: `frontend/src/lib/api.ts:56-60`.

### Q23: Why did you choose a Modular Monolith architecture instead of Microservices?
- **Direct Answer**: A Modular Monolith provides strict ACID transactional boundaries, simplified deployment via a single container, and zero network serialization overhead between services, while maintaining clean domain separation across modules.
- **Simple Explanation**: Microservices for a student major project add massive complexity (distributed transactions, API gateways, Kubernetes) with no performance benefit. A modular monolith gives clean code without distributed headaches.
- **Code Connection**: All modules live under `backend/app/services/` with decoupled responsibilities.

### Q24: How is Monaco Editor integrated into Next.js?
- **Direct Answer**: Dynamically imported using Next.js `dynamic()` with `ssr: false` to prevent server-side Node.js rendering of browser DOM elements, styled with theme synchronization in `CodeEditor.tsx`.
- **Simple Explanation**: Monaco is loaded only in the student's browser tab because it requires browser window objects that don't exist on the server.
- **Code Connection**: `frontend/src/components/CodeEditor.tsx:7-10`.

### Q25: How do Recharts components receive data from the backend?
- **Direct Answer**: The `/analytics` page calls `GET /api/v1/me/analytics?days=30`. The backend aggregates attempt records into structured arrays, and Recharts renders declarative `<Line>`, `<Bar>`, and `<ResponsiveContainer>` SVG components.
- **Simple Explanation**: The backend calculates the daily accuracy numbers and sends a clean JSON list, which Recharts converts into an animated SVG graph.
- **Code Connection**: `frontend/src/components/charts.tsx` and `src/app/(app)/analytics/page.tsx`.

### Q26: What is Pydantic v2 and where is it used?
- **Direct Answer**: Pydantic v2 is a high-performance data parsing and validation library written in Rust. It defines our API request/response schemas, validates environment settings, and parses LLM structured JSON outputs.
- **Simple Explanation**: It acts as a strict bouncer for data: if incoming JSON is missing a required field or has the wrong type, Pydantic immediately rejects it with a clear error message.
- **Code Connection**: `backend/app/schemas/` and `app/core/config.py:Settings`.

### Q27: How are background jobs dispatched when Redis is not available?
- **Direct Answer**: `app/services/jobs.py` checks if `settings.redis_url` is configured. If empty, it falls back to in-process execution using `asyncio.create_task()` after sending the HTTP response.
- **Simple Explanation**: If Redis is running, jobs go to Celery. If running locally without Redis, Python runs the background task in its own event loop so local testing works with zero setup.
- **Code Connection**: `backend/app/services/jobs.py:42-55`.

### Q28: How do you prevent frontend TypeScript errors from breaking production builds?
- **Direct Answer**: By enforcing strict type matching in `src/lib/types.ts` mirroring backend Pydantic schemas, validated via `tsc --noEmit` which currently passes with 0 errors across all 28 routes.
- **Simple Explanation**: We run the TypeScript compiler to ensure every component receives exactly the data types it expects before building the production app.
- **Code Connection**: `frontend/tsconfig.json` and `frontend/package.json`.

### Q29: What is the purpose of the `(app)` route grouping in Next.js?
- **Direct Answer**: It creates a logical route boundary in the App Router that applies a common authenticated shell (`AppShell.tsx`, sidebar, navigation) to student pages without affecting the URL path structure.
- **Simple Explanation**: The folder name `(app)` groups dashboard pages together under one layout without adding `/app/` into the browser web address.
- **Code Connection**: `frontend/src/app/(app)/layout.tsx`.

### Q30: How is database migration managed across schema updates?
- **Direct Answer**: Using Alembic with asynchronous configuration in `backend/alembic/env.py`. Migration `0001_initial.py` creates all 17 tables, indexes, and pgvector vector columns.
- **Simple Explanation**: Alembic tracks database version history in code, ensuring every team member and deployment has the exact same database structure.
- **Code Connection**: `backend/alembic/versions/0001_initial.py`.

---

## Section C: Database and SQL (15 Questions)

### Q31: What database engine is used in production versus local development?
- **Direct Answer**: PostgreSQL 16 with the `pgvector` extension is used in production (orchestrated via Docker Compose); SQLite (`dev.db` via `aiosqlite`) is used for local development and automated testing.
- **Simple Explanation**: PostgreSQL is our full-scale production database; SQLite is our zero-setup development database that runs without installing extra software.
- **Code Connection**: `backend/app/core/config.py:14` and `docker-compose.yml:2-19`.

### Q32: How do you handle vector embeddings in SQLite during local development?
- **Direct Answer**: In `app/models/base.py`, our custom `Embedding` TypeDecorator checks the dialect: on PostgreSQL, it compiles to `vector(768)`; on SQLite, it compiles to JSON, and cosine similarity is computed in Python (`rag.py:_cos`).
- **Simple Explanation**: SQLite doesn't natively support vector math, so our code automatically stores embeddings as JSON lists and computes vector distances using a Python math fallback.
- **Code Connection**: `backend/app/models/base.py:38-54` and `backend/app/services/rag.py:106-125`.

### Q33: What is the relationship between `users`, `profiles`, and `sessions`?
- **Direct Answer**: `users` has a 1:1 relationship with `profiles` (`uselist=False`, cascade delete) and a 1:many relationship with `sessions` (cascade delete).
- **Simple Explanation**: Each user has exactly one profile chart, but can have multiple active login sessions (e.g. on their phone and laptop).
- **Code Connection**: `backend/app/models/identity.py:30-33` and `39-50`.

### Q34: What is the purpose of the `question_companies` association table?
- **Direct Answer**: It establishes a many-to-many relationship between `questions` and `companies`, allowing a single problem (e.g. "Two Sum") to be tagged to Amazon, TCS, and Microsoft simultaneously.
- **Composite Primary Key**: `(question_id, company_id)`.
- **Code Connection**: `backend/app/models/content.py:6-12`.

### Q35: How is question confidentiality preserved in the database?
- **Direct Answer**: In `questions`, fields `answer`, `explanation`, and `meta["hidden_tests"]` store confidential data. Student API endpoints query through `QuestionStudentView` which excludes these columns before returning JSON.
- **Simple Explanation**: Confidential answers live in the database table, but our API filters them out so students cannot inspect them using browser developer tools.
- **Code Connection**: `backend/app/routers/questions.py` and `app/schemas/content.py`.

### Q36: What is stored in the `verdicts` table?
- **Direct Answer**: It stores the authoritative evaluation of a submission: `submission_id` (1:1), `status` (accepted, wrong_answer, TLE, etc.), `is_correct` (bool), `score` (float), `judged_by` (`judge0` or `auto`), and `details` (JSON execution metrics).
- **Code Connection**: `backend/app/models/domain.py:131-144`.

### Q37: How does the `mastery` table ensure unique records per skill?
- **Direct Answer**: By enforcing a composite unique constraint: `__table_args__ = (UniqueConstraint("user_id", "skill_id"),)`.
- **Simple Explanation**: A student can only have one mastery row per skill; new attempts update the existing row rather than inserting duplicate records.
- **Code Connection**: `backend/app/models/domain.py:162`.

### Q38: What is stored in the `ai_traces` table?
- **Direct Answer**: Comprehensive observability data for every AI call: `user_id`, `call_type`, `agent`, `model`, `prompt_tokens`, `completion_tokens`, `latency_ms`, `cost_usd`, `success`, and `error`.
- **Simple Explanation**: It is our audit log that tracks how much every AI query cost, how many tokens it consumed, and how fast it responded.
- **Code Connection**: `backend/app/models/domain.py:221-238`.

### Q39: What index is used for vector search in PostgreSQL?
- **Direct Answer**: An **HNSW (Hierarchical Navigable Small World)** index on the `documents.embedding` column using cosine distance ops (`vector_cosine_ops`).
- **Simple Explanation**: HNSW creates a multi-layered geometric graph that allows searching through thousands of embeddings in sub-millisecond logarithmic time.
- **Code Connection**: Created in Alembic migration `0001_initial.py`.

### Q40: What happens to child records when a user deletes their account?
- **Direct Answer**: Foreign key definitions specify `ondelete="CASCADE"`. Deleting a user row automatically and permanently purges all associated records in `profiles`, `sessions`, `attempts`, `submissions`, `mastery`, `interviews`, `roadmaps`, and `notifications`.
- **Simple Explanation**: The database automatically cleans up all student records in one transaction, leaving zero orphan records.
- **Code Connection**: `backend/app/models/identity.py` and `app/models/domain.py`.

### Q41: How are soft states tracked in timed assessments?
- **Direct Answer**: In the `attempts.state` JSON column, which stores draft answers per question ID (`state["responses"] = {qid: answer}`), flagged question IDs, and section timer checkpoints.
- **Code Connection**: `backend/app/models/domain.py:106` and `app/routers/tests.py:save_answer()`.

### Q42: What is the difference between `Submission.mode = "run"` and `"submit"`?
- **Direct Answer**: `mode="run"` executes code against visible sample test cases only and **never updates skill mastery**; `mode="submit"` executes code against hidden test cases, records authoritative verdicts, and triggers mastery updates.
- **Simple Explanation**: "Run" is a risk-free trial test; "Submit" is the official graded submission.
- **Code Connection**: `backend/app/models/domain.py:120` and `app/services/readiness_data.py:43`.

### Q43: How do you prevent SQL Injection in PrepPath?
- **Direct Answer**: By using SQLAlchemy 2.0 type-annotated mapped models and parameterized SQL statements (`select(User).where(User.email == email)`). User input is never concatenated into raw SQL strings.
- **Simple Explanation**: SQLAlchemy automatically escapes and parameterizes all inputs, separating SQL code from user data and completely neutralizing SQL injection attacks.
- **Code Connection**: Used across all repository routers (e.g. `app/routers/auth.py:65`).

### Q44: What is stored in the `readiness_scores` table?
- **Direct Answer**: Historical snapshots of Equation 3.1 calculations: `user_id`, `company_id`, `overall` (float), `components` (JSON dictionary of 6 sub-scores), `weights` (JSON dictionary of weights used), and `computed_at`.
- **Code Connection**: `backend/app/models/domain.py:65-75`.

### Q45: How is database connection pooling configured?
- **Direct Answer**: Configured in `backend/app/core/db.py` using SQLAlchemy `create_async_engine()`, setting pool size and recycling connections to avoid stale socket timeouts.
- **Code Connection**: `backend/app/core/db.py:15-28`.

---

## Section D: Artificial Intelligence and LLMs (15 Questions)

### Q46: What Generative AI models are used in PrepPath?
- **Direct Answer**: Google Gemini models: `gemini-flash-lite-latest` for fast/cheap tasks, `gemini-flash-latest` for strong reasoning tasks, and `gemini-embedding-001` for 768-dimensional vector embeddings.
- **Code Connection**: `backend/app/core/config.py:42-45` and `app/services/llm.py:34-37`.

### Q47: What is model routing and why do you use it?
- **Direct Answer**: Model routing directs tasks to the most cost-effective LLM based on task complexity. Simple tasks (hints, trivia) route to the fast model ($0.10/1M tokens); high-stakes tasks (interview evaluations, code reviews) route to the strong model ($0.30/1M tokens).
- **Simple Explanation**: You don't use a Ferrari to buy groceries. We use a cheap, fast model for simple queries and reserve our heavy model for difficult evaluations, saving 70% in token costs.
- **Code Connection**: `backend/app/services/llm.py:34-37` (`STRONG_TASKS` set).

### Q48: How do you force Google Gemini to output structured JSON instead of markdown prose?
- **Direct Answer**: By setting `response_mime_type="application/json"` and passing an inlined JSON Schema via Gemini's `response_schema` parameter, derived automatically from our Pydantic models.
- **Simple Explanation**: We send the exact JSON blueprint to the model, and Gemini's decoding engine forces the output tokens to conform to our JSON structure.
- **Code Connection**: `backend/app/services/llm.py:json_schema()` and `GeminiClient.generate()`.

### Q49: What happens if the LLM output violates your Pydantic schema?
- **Direct Answer**: Pydantic raises a `ValidationError`. Our service catches the exception, logs the failure in `ai_traces`, and triggers an automated retry or safe deterministic fallback rather than crashing the API.
- **Code Connection**: `backend/app/services/llm.py:structured()`.

### Q50: How do you prevent Prompt Injection attacks?
- **Direct Answer**: In `app/services/guardrails.py:clean_input()`, we scan user text for injection patterns (e.g. `ignore previous instructions`), strip control characters, and encapsulate user input inside `<student_input>...</student_input>` XML tags in the prompt.
- **Simple Explanation**: We filter out malicious hacking prompts and wrap student text in special delimiters so the AI treats it strictly as content to read, not commands to execute.
- **Code Connection**: `backend/app/services/guardrails.py:33-52` and `wrap_student()`.

### Q51: How does your AI Code Review ensure it doesn't overturn the judge's verdict?
- **Direct Answer**: First, it refuses to run unless Judge0 has returned an authoritative verdict; second, the Pydantic schema `CodeReviewOut` has no score/verdict field; third, `strip_verdict_contradictions()` removes any sentence claiming the code failed if Judge0 marked it Accepted.
- **Code Connection**: `backend/app/services/code_review.py:38-46` and `71-84`.

### Q52: What is the Daily Token Budget in PrepPath?
- **Direct Answer**: 150,000 tokens per user per 24-hour rolling window (prompt + completion tokens combined).
- **Simple Explanation**: Each student gets a generous daily budget of ~100 tutoring interactions. If they exceed it, the system pauses AI requests until tomorrow to prevent automated scraping or runaway API costs.
- **Code Connection**: `backend/app/core/config.py:48` and `app/services/llm.py:check_budget()`.

### Q53: What is the Rate Limit on AI requests?
- **Direct Answer**: 12 requests per minute per authenticated student.
- **Simple Explanation**: Prevents students from spamming the "Ask AI" button rapidly.
- **Code Connection**: `backend/app/core/config.py:47`.

### Q54: How does AI response caching work?
- **Direct Answer**: Responses are cached using a composite SHA-256 hash key combining user query and retrieved chunk IDs, with a 6-hour TTL (`ai_cache_ttl_seconds = 21600`) stored in Redis or memory.
- **Simple Explanation**: If two students ask the same question on the same topic, the second student receives the cached answer in 20ms without paying for another Gemini API call.
- **Code Connection**: `backend/app/services/llm.py:structured()` and `app/core/config.py:49`.

### Q55: What is temperature in LLM generation and what value do you use?
- **Direct Answer**: Temperature controls randomness in token sampling. In PrepPath, we use a low temperature ($0.2$) for factual tutoring, code review, and evaluation, and a moderate temperature ($0.6$) for mock interview turn generation.
- **Simple Explanation**: Low temperature makes the AI deterministic and factual; higher temperature makes it more creative and conversational.
- **Code Connection**: `backend/app/services/llm.py:structured(temperature=0.2)`.

### Q56: What is the offline Mock Mode in your AI service?
- **Direct Answer**: Implemented via `MockLLMClient` in `app/services/llm.py`. When `GEMINI_API_KEY` is empty, it returns deterministic, realistic mock JSON models with zero external network dependencies.
- **Simple Explanation**: It allows our entire platform to be tested and demonstrated completely offline without an internet connection or paid API key.
- **Code Connection**: `backend/app/services/llm.py:MockLLMClient` and `app/core/config.py:llm_mock_mode`.

### Q57: How do you calculate estimated AI costs in `ai_traces`?
- **Direct Answer**: In `app/services/llm.py:PRICE`, we multiply prompt tokens by input rates ($0.10/1M flash-lite, $0.30/1M flash) and completion tokens by output rates ($0.40/1M flash-lite, $2.50/1M flash).
- **Code Connection**: `backend/app/services/llm.py:40` and `record_trace()`.

### Q58: Can the AI Tutor see the confidential answer key?
- **Direct Answer**: Yes, but only in Hint Mode with strict guardrails: the prompt passes the answer labeled `CONFIDENTIAL ANSWER KEY (never reveal, quote or paraphrase it)`, and the output is scanned against `forbidden_fragments` to guarantee zero answer leakage.
- **Code Connection**: `backend/app/services/tutor.py:197-202`.

### Q59: What is the role of Generative AI in the Resume Gap Analysis?
- **Direct Answer**: The LLM is used strictly for asynchronous entity extraction (parsing messy PDF text into structured Pydantic schemas: `skills`, `projects`, `education`). The subsequent matching and readiness scoring is 100% deterministic.
- **Code Connection**: `backend/app/services/career.py:parse_resume()`.

### Q60: How does PrepPath prevent LLM hallucinations during study sessions?
- **Direct Answer**: Through RAG grounding: the model is given verified syllabus chunks and explicitly commanded to answer using only the provided sources. If cosine similarity is below 0.55, the model refuses to answer rather than guessing.
- **Code Connection**: `backend/app/services/tutor.py:140-147`.

---

## Section E: RAG and Vector Databases (15 Questions)

### Q61: What does RAG stand for and what does it do?
- **Direct Answer**: Retrieval-Augmented Generation. It retrieves semantically relevant document chunks from an external vector database and injects them into the LLM's prompt as grounded reference context before generating an answer.
- **Simple Explanation**: It gives the AI an "open book" of verified course notes to consult before answering student questions.
- **Code Connection**: `backend/app/services/rag.py`.

### Q62: What is the dimensional size of your embeddings?
- **Direct Answer**: 768 dimensions, produced by Google Gemini's `gemini-embedding-001` model.
- **Code Connection**: `backend/app/core/config.py:45` and `app/models/base.py:EMBEDDING_DIM = 768`.

### Q63: How are documents chunked before embedding?
- **Direct Answer**: In `app/services/rag.py:chunk_text()`, text is split on paragraph breaks (`\n\n`) with `size = 900` characters and `overlap = 150` characters, snapping giant paragraphs to the nearest sentence boundary (`. `).
- **Simple Explanation**: We split long documents into bite-sized paragraphs so each chunk represents one coherent concept.
- **Code Connection**: `backend/app/services/rag.py:19-20` and `41-68`.

### Q64: Why is character overlap between chunks necessary?
- **Direct Answer**: Overlap ensures that semantic context spanning across chunk boundaries is preserved, preventing split sentences or broken algorithmic proofs from losing their meaning.
- **Simple Explanation**: A 150-character overlap repeats the end of paragraph 1 at the start of paragraph 2 so concepts on the edge aren't lost.
- **Code Connection**: `backend/app/services/rag.py:20`.

### Q65: What is Cosine Similarity and what is its range?
- **Direct Answer**: Cosine similarity is the cosine of the angle between two vector embeddings: $\frac{A \cdot B}{\|A\| \|B\|}$. Its mathematical range is $[-1, 1]$, where $1.0$ indicates identical direction and $0.0$ indicates orthogonality.
- **Code Connection**: `backend/app/services/rag.py:_cos()`.

### Q66: What is the difference between Cosine Distance and Cosine Similarity in pgvector?
- **Direct Answer**: In pgvector, Cosine Distance is defined as $1 - \text{Cosine Similarity}$. A distance of $0.0$ means identical vectors; a distance of $1.0$ means completely unrelated vectors. pgvector uses the `<=>` operator to order by ascending distance.
- **Code Connection**: `backend/app/services/rag.py:119-122`.

### Q67: What is an HNSW index and why is it superior to IVFFlat?
- **Direct Answer**: Hierarchical Navigable Small World (HNSW) is a graph-based approximate nearest neighbor index. Unlike IVFFlat, which partitions vector space into Voronoi cells and requires retraining, HNSW provides superior recall, sub-millisecond search latency, and supports dynamic insertions without full re-indexing.
- **Code Connection**: Created in Alembic migration `0001_initial.py`.

### Q68: What is your similarity floor threshold in RAG search?
- **Direct Answer**: `MIN_SCORE_REAL = 0.55` for Gemini embeddings (and `0.05` for hash-based mock embeddings).
- **Simple Explanation**: If the best matching document chunk has a similarity below 0.55, the system deems it irrelevant and refuses to call the LLM.
- **Code Connection**: `backend/app/services/rag.py:21-22` and `136`.

### Q69: What is metadata boosting in your vector search?
- **Direct Answer**: In `app/services/rag.py:127-133`, we add $+0.05$ to the similarity score if the chunk's `topic_id` matches the query topic, and $+0.05$ if its `company_id` matches the target company.
- **Simple Explanation**: We give a small bonus to documents that belong to the exact subject or company the student is studying.
- **Code Connection**: `backend/app/services/rag.py:127-133` (`boost()`).

### Q70: How are citations formatted and verified?
- **Direct Answer**: Chunks receive reference keys `[S1]`, `[S2]`. The LLM cites these keys in its Pydantic output. `guardrails.py:check_citations()` verifies that every emitted key matches an actually retrieved chunk ID; hallucinated tags are stripped.
- **Code Connection**: `backend/app/services/guardrails.py:check_citations()` and `app/services/tutor.py:109`.

### Q71: What are the six bounded modes of your AI Tutor?
- **Direct Answer**:
  1. `explain`: Socratic conceptual explanation with key points and examples.
  2. `hint`: Directional non-leaking hint.
  3. `interviewer`: Company-focused interview question.
  4. `evaluate`: Scoring written responses 0–10 against concepts.
  5. `followup`: Probing edge cases from the previous exchange.
  6. `revision`: Targeted practice questions based on past incorrect answers.
- **Code Connection**: `backend/app/services/tutor.py:128-333`.

### Q72: How does the AI Tutor handle out-of-corpus queries like "Who won the World Cup?"
- **Direct Answer**: The vector search finds no chunks with cosine similarity $\ge 0.55$. The tutor immediately returns: *"The course knowledge base doesn't cover this yet, so I won't guess. Try rephrasing, or ask about a topic from the syllabus."* The LLM is never called.
- **Code Connection**: `backend/app/services/tutor.py:140-147`.

### Q73: What was the measured Faithfulness in your RAG evaluation harness?
- **Direct Answer**: **0.857** (85.7% of generated claims directly supported by retrieved chunks), measured in `benchmarks/rag_eval_harness.py` and saved to `rag_eval_results.json`.
- **Code Connection**: `backend/benchmarks/rag_eval_results.json:3`.

### Q74: What was the measured Refusal Correctness in your RAG evaluation harness?
- **Direct Answer**: **1.000** (100% refusal rate on out-of-corpus adversarial queries, achieving zero hallucinations).
- **Code Connection**: `backend/benchmarks/rag_eval_results.json:8`.

### Q75: How long does a vector search take in PrepPath?
- **Direct Answer**: Measured mean latency of **15.58 milliseconds** (p95 latency of 16.42 ms) across 25 benchmark samples.
- **Code Connection**: `backend/benchmarks/pipeline_benchmarks.json:29`.

---

## Section F: Agentic AI and Orchestration (15 Questions)

### Q76: What is the role of the Triage Agent in PrepPath?
- **Direct Answer**: The Triage Agent acts as the central router. It classifies free-form student queries into one of 6 intents (`tutor`, `assessment`, `interview`, `placement_roadmap`, `analytics`, `recommendation`) with a confidence score and reasoning.
- **Code Connection**: `backend/app/services/agents/orchestrator.py:triage_student_intent()`.

### Q77: List all seven agents in your multi-agent architecture.
- **Direct Answer**:
  1. Triage Agent (Intent router)
  2. Tutor Agent (Socratic RAG tutor)
  3. Assessment Agent (Diagnostic question selector)
  4. Interview Agent (Mock interview conversationalist)
  5. Placement Agent (Company roadmap planner)
  6. Analytics Agent (Readiness auditor)
  7. Recommendation Agent (Dynamic plan reviser)
- **Code Connection**: `backend/app/services/agents/orchestrator.py`.

### Q78: Are your agents truly autonomous?
- **Direct Answer**: No, they are **bounded agents coordinated through a central orchestrator**. They do not converse autonomously with each other; they execute dedicated tasks bounded by Pydantic contracts and database state.
- **Simple Explanation**: Autonomous agents that talk to each other without limits cause infinite loops and massive token bills. Our orchestrator directs them step-by-step with strict contracts.
- **Code Connection**: `backend/app/services/agents/orchestrator.py:execute_agent_workflow()`.

### Q79: How does the Placement Agent synthesize a daily roadmap?
- **Direct Answer**: In `orchestrator.py:placement_agent_build_roadmap()`, it accepts target company, preparation days (e.g. 20), daily study hours (e.g. 2.5), current skill summary, and weak topics. Gemini Strong synthesizes a `GeneratedRoadmapPlanOut` with daily topics, problem allocations, and mini-assessments.
- **Code Connection**: `backend/app/services/agents/orchestrator.py:99-132`.

### Q80: What triggers the Recommendation Agent to revise a roadmap?
- **Direct Answer**: A performance trigger: when a student scores below 50% on a topic assessment (e.g. Graphs), `app/services/roadmap.py:revise_roadmap()` invokes the Recommendation Agent to adapt the active plan.
- **Code Connection**: `backend/app/services/roadmap.py:129-193`.

### Q81: What specific changes does the Recommendation Agent make during roadmap revision?
- **Direct Answer**: It extends revision on the struggled topic by adding remedial foundational concepts, postpones advanced topics (e.g. Segment Trees) to later days to maintain time realism, increments the roadmap version, and commits a revision reason.
- **Code Connection**: `backend/app/services/agents/orchestrator.py:RoadmapRevisionOut`.

### Q82: Where are recommendations logged for student visibility?
- **Direct Answer**: In the `recommendations` table (`app/models/domain.py:189-200`) with `kind` (`plan_revision`, `daily_milestone`), `payload`, and `reason`.
- **Code Connection**: `backend/app/services/roadmap.py:178-189`.

### Q83: How do you prevent conflicts between two agents?
- **Direct Answer**: By enforcing single-agent ownership per state transition through the central orchestrator. An agent can only emit structured data matching its contract; it cannot overwrite another agent's domain state.
- **Code Connection**: Handled via orchestrator functions in `app/services/agents/orchestrator.py`.

### Q84: How are mock interview transcripts managed across multiple turns?
- **Direct Answer**: As a JSON list of turn objects (`[{"speaker": "interviewer" | "student", "text": "...", "timestamp": "..."}]`) stored in `interviews.transcript`. Each turn appends to this list.
- **Code Connection**: `backend/app/models/domain.py:214` and `app/services/interview.py:141-182`.

### Q85: What are the five rubric dimensions evaluated by the Interview Agent?
- **Direct Answer**:
  1. Technical Knowledge (1–10)
  2. Problem Solving (1–10)
  3. Communication (1–10)
  4. Confidence (1–10)
  5. Concept Accuracy (1–10)
- **Code Connection**: `backend/app/services/interview.py:InterviewEvaluationOut`.

### Q86: How is the mock interview score connected to the Company Readiness Score?
- **Direct Answer**: The five rubric scores are averaged to produce an `overall_score` on a $0–100$ scale. In `readiness_data.py:91-100`, the readiness engine queries completed interviews and sets the 10% Interview component equal to this average.
- **Code Connection**: `backend/app/services/interview.py:236-244` and `app/services/readiness_data.py:91-100`.

### Q87: Does your Mock Interview system analyze voice or facial video?
- **Direct Answer**: No. Communication and Confidence are inferred strictly from written response clarity, structure, and decisiveness. Our UI displays an explicit ethical disclosure stating this boundary.
- **Code Connection**: `backend/app/services/interview.py:view()` ("disclaimer" field).

### Q88: How does the Assessment Agent choose the next diagnostic question?
- **Direct Answer**: Deterministically via `app/services/mastery.py:target_difficulty()`: if student mastery is $<35$, it chooses an Easy question; if $35\text{--}70$, a Medium question; if $\ge 70$, a Hard question.
- **Code Connection**: `backend/app/services/mastery.py:99-102`.

### Q89: What happens when a student marks a roadmap day as complete?
- **Direct Answer**: `complete_milestone()` appends the day number to `roadmap.plan["completed_days"]`, awards XP via the engagement layer, and updates progress bars.
- **Code Connection**: `backend/app/services/roadmap.py:195-214`.

### Q90: Why did you use Pydantic models for agent handoffs instead of plain strings?
- **Direct Answer**: Pydantic models enforce strict schema validation, type safety, field length limits, and clear failure modes. If an agent outputs invalid data, it fails fast at the boundary rather than corrupting downstream database tables.
- **Code Connection**: `backend/app/services/agents/orchestrator.py:22-57`.

---

## Section G: Algorithms, Mastery and Readiness Score (15 Questions)

### Q91: State Equation 3.1 for the Company Readiness Score.
- **Direct Answer**:
  $$\text{CRS} = 0.25(\text{DSA}) + 0.20(\text{CSF}) + 0.20(\text{Coding}) + 0.15(\text{Aptitude}) + 0.10(\text{Interview}) + 0.10(\text{Consistency})$$
- **Code Connection**: `backend/app/services/readiness.py:13-15` and `36-43`.

### Q92: What does the DSA component measure in Equation 3.1?
- **Direct Answer**: A 70/30 blend of skill-graph DSA mastery and the acceptance ratio of distinct DSA coding problems:
  $$\text{DSA} = 0.70 \cdot \text{DSA\_Mastery} + 0.30 \cdot \left(\frac{\text{DSA\_Accepted}}{\text{DSA\_Attempted}} \times 100\right)$$
- **Code Connection**: `backend/app/services/readiness.py:52-60`.

### Q93: How is CS Fundamentals (CSF) calculated in Equation 3.1?
- **Direct Answer**: It is the weighted average of skill graph mastery across the four core CSF domains: DBMS, Operating Systems, Computer Networks, and Object-Oriented Programming (OOP).
- **Code Connection**: `backend/app/services/readiness_data.py:103-104` (`CSF_AREAS`).

### Q94: How is Coding Performance calculated in Equation 3.1?
- **Direct Answer**: 70% accepted problem ratio plus 30% mean solve speed of accepted Judge0 submissions:
  $$\text{Coding} = 70 \cdot \left(\frac{\text{Accepted}}{\text{Attempted}}\right) + 30 \cdot \text{mean}(\text{Speed})$$
  $$\text{Speed} = \min\left(1.0, \frac{\text{Expected Time (ms)}}{\text{Actual Time (ms)}}\right)$$
- **Code Connection**: `backend/app/services/readiness.py:63-74`.

### Q95: How is Consistency calculated in Equation 3.1?
- **Direct Answer**: Half current study streak (capped at 14 days) and half active day share in a 14-day sliding window:
  $$\text{Consistency} = 50 \cdot \left(\frac{\min(\text{Streak}, 14)}{14}\right) + 50 \cdot \left(\frac{\text{Active Days}}{14}\right)$$
- **Code Connection**: `backend/app/services/readiness.py:80-84`.

### Q96: Can target companies override Equation 3.1 weights?
- **Direct Answer**: Yes. If a company record has `readiness_weights` populated (e.g. a firm focusing 40% on DSA), those weights are validated to ensure non-negativity and sum equal to 1.0, overriding the defaults.
- **Code Connection**: `backend/app/services/readiness.py:28-34` (`validate_weights`).

### Q97: What is the Bayesian Elo update formula for skill mastery?
- **Direct Answer**:
  $$\Delta = \text{clamp}\left(\text{lr} \cdot w \cdot (\text{target} - \text{mastery}), -15.0, +15.0\right)$$
  Where $\text{target} = 100$ (correct) or $0$ (wrong), $\text{lr} = \max(0.15, 1/(n+2))$, and $w$ accounts for difficulty, speed, and confidence.
- **Code Connection**: `backend/app/services/mastery.py:56-75`.

### Q98: Why does learning rate decay as attempt count ($n$) increases?
- **Direct Answer**: Early in a student's practice ($n=0, 1$), we have little statistical evidence, so mastery must move rapidly ($\text{lr} = 0.50$). After many attempts ($n=10$), competence has stabilized, so updates become gradual ($\text{lr} = 0.15$).
- **Code Connection**: `backend/app/services/mastery.py:59`.

### Q99: How does the algorithm penalize a confident wrong answer?
- **Direct Answer**: In `app/services/mastery.py:73`, when an answer is incorrect, the weight is multiplied by $(1.0 + 0.3 \times \text{confidence})$. A student who is 100% confident in a wrong answer receives a 30% harsher penalty because it signals a fundamental misconception.
- **Code Connection**: `backend/app/services/mastery.py:72-74`.

### Q100: How is solve speed factored into mastery updates?
- **Direct Answer**: On correct answers, weight is scaled by $\text{clamp}(1.2 - 0.2 \times (\text{time} / \text{expected}), 0.8, 1.1)$. Solving faster than expected awards up to a 10% bonus; solving much slower reduces the gain by 20%.
- **Code Connection**: `backend/app/services/mastery.py:65-66`.

### Q101: What is the time complexity of updating skill mastery?
- **Direct Answer**: $O(1)$ constant time. It executes pure floating-point arithmetic with zero loops or database queries.
- **Code Connection**: `backend/app/services/mastery.py:update_mastery()`.

### Q102: How does the system rank student weaknesses?
- **Direct Answer**: In `readiness_data.py:rank_weaknesses()`, leaf topics are sorted by priority:
  $$\text{Priority} = (100 - \text{Mastery}) \times \text{Company Emphasis} \times \text{Frequent Topic Multiplier}$$
- **Code Connection**: `backend/app/services/readiness.py:96-116`.

### Q103: How does the system calculate the single "Worst Gap Recommendation"?
- **Direct Answer**: In `readiness_data.py:recommend()`, it calculates the weighted deficit for all 6 components: $\text{Deficit}(k) = w_k \times (100 - \text{Score}_k)$, and selects the component with the largest deficit.
- **Code Connection**: `backend/app/services/readiness_data.py:150-182`.

### Q104: How is Job Readiness % calculated in Resume Gap Analysis?
- **Direct Answer**:
  $$\text{Job Readiness \%} = 100 \times \frac{\sum_{\text{Matched}} \text{Weight}}{\sum_{\text{Total Requirements}} \text{Weight}}$$
  Where required skills carry weight 2, and preferred technologies carry weight 1.
- **Code Connection**: `backend/app/services/career.py:207-208`.

### Q105: How does the assessment engine calculate final test scores?
- **Direct Answer**: In `app/services/grading.py:grade_attempt()`, it sums positive marks for correct answers, deducts negative marks for incorrect answers (if enabled), and scores coding questions proportionally based on Judge0 passed test case ratios.
- **Code Connection**: `backend/app/services/grading.py`.

---

## Section H: Security, Testing and Deployment (10 Questions)

### Q106: How do you prevent student code from accessing host server files or environment secrets?
- **Direct Answer**: Code is never executed on the FastAPI host. It is dispatched to an isolated Judge0 CE container running in unprivileged Linux cgroups with read-only filesystems and seccomp filters that block system calls.
- **Code Connection**: `backend/app/services/judge.py`.

### Q107: What is the structure of your refresh token cookie?
- **Direct Answer**: Set with `httpOnly=True`, `SameSite="Lax"`, `secure=False` (in dev) / `True` (in prod), `path="/api/v1/auth"`, and `max_age = 14 \text{ days}`.
- **Code Connection**: `backend/app/routers/auth.py:48-55`.

### Q108: How do you prevent Cross-Site Scripting (XSS) attacks from stealing student tokens?
- **Direct Answer**: The access token is stored strictly in module-scoped JavaScript memory, and the refresh token is an httpOnly cookie. JavaScript running in the browser has zero access to storage APIs holding tokens.
- **Code Connection**: `frontend/src/lib/api.ts:4-8`.

### Q109: How does the system validate uploaded resume files?
- **Direct Answer**: In `career.py:validate_upload()`, it checks file extensions (`.pdf`, `.txt`), verifies that file size is $\le 5\text{MB}$, verifies matching MIME types, and inspects magic bytes (`b"%PDF-"`).
- **Code Connection**: `backend/app/services/career.py:65-84`.

### Q110: How many automated unit tests exist in your test suite and do they pass?
- **Direct Answer**: 90 automated backend tests across 12 test files running on `pytest`. All 90 tests pass in 25.13 seconds using an in-memory SQLite database.
- **Code Connection**: `backend/tests/`.

### Q111: What is verified by `test_functional_traceability.py`?
- **Direct Answer**: It executes 15 end-to-end integration tests verifying Report Table 4.2 functional requirements T01 through T16 and T19 (auth, RBAC, study loops, Judge0, Equation 3.1, and analytics).
- **Code Connection**: `backend/tests/test_functional_traceability.py`.

### Q112: How are Docker containers configured for production?
- **Direct Answer**: Using multi-stage Dockerfiles: backend runs on `python:3.12-slim` under non-root user `appuser`; frontend runs on `node:22-alpine` leveraging Next.js standalone output (118MB image size).
- **Code Connection**: `backend/Dockerfile` and `frontend/Dockerfile`.

### Q113: What services are orchestrated in your `docker-compose.yml`?
- **Direct Answer**: Six containers: `postgres` (pgvector/pgvector:16), `redis` (redis:7-alpine), `backend` (FastAPI), `worker` (Celery), `frontend` (Next.js), and `judge0` (Judge0 CE).
- **Code Connection**: `major1/docker-compose.yml`.

### Q114: How does GDPR / DPDP Student Data Portability work in your platform?
- **Direct Answer**: `GET /api/v1/users/me/export` queries 8 database tables (profile, mastery, attempts, submissions, readiness, resumes, interviews, roadmaps) and streams an auditable, structured JSON document.
- **Code Connection**: `backend/app/routers/users.py:62-217`.

### Q115: How does account deletion work?
- **Direct Answer**: `DELETE /api/v1/users/me` unlinks and physically deletes uploaded resume files from the server disk, and deletes the user row. Database foreign keys with `ondelete="CASCADE"` automatically purge all associated records.
- **Code Connection**: `backend/app/routers/users.py:219-245`.

---

## Section I: Project Differentiation and Future Scope (10 Questions)

### Q116: What is the single biggest architectural differentiator of PrepPath?
- **Direct Answer**: The strict architectural boundary separating deterministic execution (Judge0 sandboxed verdicts and Equation 3.1 Readiness Scores) from bounded generative AI (RAG Socratic tutoring and mock interviews).
- **Simple Explanation**: We never let AI grade code or invent scores; AI is strictly a tutor, while math and containers do the grading.

### Q117: How is PrepPath's mastery tracking superior to LeetCode's problem counts?
- **Direct Answer**: LeetCode simply reports "150 problems solved", treating a brute-force solution the same as an optimal solution. PrepPath computes a continuous Elo rating incorporating problem difficulty, solve time efficiency, and confidence penalties.
- **Code Connection**: `backend/app/services/mastery.py`.

### Q118: Why is PrepPath's roadmap engine considered "dynamic"?
- **Direct Answer**: Because the roadmap adapts in real-time. If an assessment reveals a topic score below 50%, the Recommendation Agent dynamically adapts the plan—inserting remedial revision and postponing advanced topics.
- **Code Connection**: `backend/app/services/roadmap.py:revise_roadmap()`.

### Q119: What is the biggest current limitation of the platform?
- **Direct Answer**: Mock interviews evaluate written text structure and precision rather than vocal audio acoustics or facial video expressions, which we disclose explicitly in the UI.
- **Code Connection**: `backend/app/services/interview.py:view()`.

### Q120: How would you scale PrepPath to handle 10,000 simultaneous students?
- **Direct Answer**: Deploy PostgreSQL read-replicas with PgBouncer connection pooling, distribute Judge0 across a multi-node Kubernetes cluster with Redis queue partitioning, and buffer draft test answers in Redis before batch-committing to PostgreSQL.

### Q121: How would you validate Equation 3.1 statistically?
- **Direct Answer**: Conduct a longitudinal cohort study with our college placement cell tracking 500 students, correlating PrepPath readiness scores with actual placement outcomes using Receiver Operating Characteristic (ROC) analysis and Area Under the Curve (AUC).

### Q122: Why did you implement an opt-in leaderboard instead of a public competitive leaderboard?
- **Direct Answer**: In accordance with institutional psychological guidelines, mandatory public leaderboards induce unhealthy anxiety. Students must explicitly opt-in via profile settings before their rank is displayed.
- **Code Connection**: `backend/app/services/notifications.py:get_leaderboard()`.

### Q123: What happens if an external Judge0 public instance goes down?
- **Direct Answer**: The submission is flagged with verdict `internal_error`, nothing is scored, no mastery is deducted, and the student is informed cleanly to retry without losing their draft code.
- **Code Connection**: `backend/app/services/judge.py:50` and `frontend/src/components/CodeWorkbench.tsx:50`.

### Q124: What is the purpose of the Admin AI Review Queue?
- **Direct Answer**: To ensure that AI-generated questions never enter the live student question bank until a human administrator or content manager reviews them, verifies them on Judge0, and approves them.
- **Code Connection**: `backend/app/routers/ai.py` and `frontend/src/app/(app)/admin/review/page.tsx`.

### Q125: What is your closing statement for the viva examination?
- **Direct Answer**: *"PrepPath demonstrates that modern AI in higher education should not replace deterministic engineering—it should enhance it. By pairing rigorous sandboxed execution and auditable Bayesian math with bounded Socratic tutoring, we provide engineering students with a transparent, personalized, and trustworthy placement preparation platform."*
